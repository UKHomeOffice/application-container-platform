## **Certificate Management**
----

The ACP platform presently has two certificate management services, the first contender was [kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager). The project due to a forever changing landscape gradually became deprecated and has now been replaced by the [cert-manager](https://github.com/jetstack/cert-manager). Note ACP will continue to support the kube-cert-manager and the internal cfssl service while they are still in use, we do however recommend shifting over to the cert-manager as aside from security fix we won't be performing anymore updates on these services.

Without wishing to duplicate documentation, which are can get from both the [readme](https://github.com/jetstack/cert-manager/blob/master/README.md) or it's official [documentation](https://cert-manager.readthedocs.io/en/latest/), the cert-manager can effectively replace two services

- kube-cert-manager: used to acquire certificates from LetsEncrypyt.
- cfssl: an internal Cloudflare service used to generate internal certificate _(usaually to encrypt between ingress and pod)_.

### **How-tos**

#### **As a developer I want to retrieve an internal certificate**

As stated above the cert-manager can also handle internal certificates i.e. those signing the internal ACP Certificate Authority _(this is self signed btw)_. At the moment you might be using [cfssl-sidekick](https://github.com/UKHomeOffice/cfssl-sidekick) to perform this, but this can be completely replaced.

```YAML
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: tls
spec:
  secretName: tls
  issuerRef:
    name: platform-tls
    kind: ClusterIssuer
  commonName: site.svc.project.cluster.local
  dnsNames:
  - localhost
  - 127.0.0.1
```

This would create a kubernetes secret named `tls` in your namespace with the signed certificate. An interesting thing to note here although this is using the ClusterIssuer platform-ca created by the ACP team, there is nothing stopping a project from creating a local Issuer for the own project. So for example.

```YAML
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  name: project-ca
spec:
  ca:
    secretName: project-ca
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: tls
spec:
  secretName: tls
  issuerRef:
    name: project-ca
    # @Note: we have change from ClusterIssuer to a local Issuer
    kind: Issuer
  commonName: site.svc.project.cluster.local
  dnsNames:
  - localhost
  - 127.0.0.1
```

#### **As a developer I want to retrieve a certificate for my external service**

Lets assume we have an externally facing site which we wish to expose via ingress and we want a valid Letsencrypt certificate. Two have two things to note here;

- the enable annotation `certmanager.k8s.io/enabled` which is a toggle to ask cert-manager to handle this ingress resource.
- the Letsencrypt challenge `certmanager.k8s.io/acme-challenge-type`; note, technically the challenge is not required as `http01` is the default type, but I'm adding to highlight.

#### **When to use a HTTP challenge**

Assuming the site is externally facing i.e. the ingress class on the ingress is `kubernetes.io/ingress.class: ingress-external` you should always default to using a http01 challenge. Things change, however, when the site is internal / behind the vpn. In order to handle the challenge when behind the VPN you need to switch to using a DNS challenge. In ingress this is done by adding the annotation `certmanager.k8s.io/acme-challenge-type: dns`. **Very Important** this assumes you have contacted the ACP beforehand and we have either added the domain to our route53 or added the dns provider as a challenge provider.

```YAML
apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      # @NOTE: we choose http challenge
      certmanager.k8s.io/acme-challenge-type: http01
      # @NOTE: this will enable the cert-manager to handle this resource
      certmanager.k8s.io/enabled: "true"
      ingress.kubernetes.io/affinity: cookie
      ingress.kubernetes.io/force-ssl-redirect: "true"
      ingress.kubernetes.io/secure-backends: "true"
      ingress.kubernetes.io/session-cookie-name: ingress
      ingress.kubernetes.io/ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx-external
    name: example
  spec:
    rules:
    - host: www.example.com
      http:
        paths:
        - backend:
            serviceName: service_name
            servicePort: 443
          path: /
    tls:
    - hosts:
      - www.example.com
      # @NOTE: this is the name of the kubernetes secret to create in your namespace
      secretName: example-tls
```

A few things to note here; the cert-manager works with the custom resource `Certificate` when using ingress annotation what the cert-manager is doing is using another internal controller to pick up the ingress resources and create a Certificate resource on your behalf. Of course you caninstead define this directly yourself.

```YAML
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: example
spec:
  acme:
    config:
    - domains:
      - www.example.com
      http01:
        ingress: ""
        ingressClass: nginx-external
  commonName: ""
  dnsNames:
  - www.example.com
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
  secretName: example-tls
```

You can review, get, list and describe the Certificate like any other kubernetes resource within your namespace.

```shell
$ kubectl -n project get certificate
NAME        AGE
example-tls    1d
```

#### **As a developer I want to retrieve a certificate for a service behind the vpn**

As stated above in order to retrieve a certificate for sites which are not externally facing we need to switch to a DNS challenge. Please ensure you have contacted the ACP team before attempting this as the correct permission need to exist to permit the cert-manager to add records to the domain.

```YAML
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: example-tls
spec:
  secretName: example-tls
  issuerRef:
    name: letsencrypt-prod
  commonName: mysite.example.com
  dnsNames:
  - example.com
  acme:
    config:
    - dns01:
        provider: dns
      domains:
      - mysite.example.com
      - example.com
```
