## **Cert Manager**
----

The ACP platform presently has two certificate management services. The first contender was [kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager), however with the forever changing landscape the project gradually became deprecated and now recommends replacement with [cert-manager](https://github.com/jetstack/cert-manager).

Note ACP will continue to support the kube-cert-manager and the internal cfssl service while they are still in use, we do however recommend shifting over to the cert-manager as aside from security fixes we won't be performing anymore updates to these services.

Without wishing to duplicate documentation which can be found in the [readme](https://github.com/jetstack/cert-manager/blob/master/README.md) and or official [documentation](https://cert-manager.readthedocs.io/en/latest/), the cert-manager can effectively replace two services.

- kube-cert-manager: used to acquire certificates from LetsEncrypt.
- cfssl: an internal Cloudflare service used to generate internal certificate _(usaually to encrypt between ingress and pod)_.

### **How-tos**

#### **As a developer I already have a certificate from the legacy kube-cert-manger, can I migrate?**

Migrating from the former [kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager) over to [cert-manager](https://github.com/jetstack/cert-manager) means creating the certificate request as below and removing the annotations from the ingress. However, the safe way would be to;

- Create a new Certificate resource and point to a **new** secret name _(thus keeping the old one incase)_.
- Push out the change and wait for the certificate to be fulfilled.
- Once you have the certificate you can update your ingress to use the new secret,**remove** the annotations and use the Certificate resource thereafter.

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

Lets assume we have an externally facing site which we wish to expose via ingress and we want a valid Letsencrypt certificate. Two things to note here;

- the enable annotation `certmanager.k8s.io/enabled` which is a toggle to ask cert-manager to handle this ingress resource.
- the Letsencrypt challenge `certmanager.k8s.io/acme-challenge-type`; note, technically the challenge is not required as `http01` is the default type, but I'm adding to highlight.

**When to use a HTTP challenge**

Assuming the site is externally facing i.e. the ingress class on the ingress is `kubernetes.io/ingress.class: ingress-external` you should always default to using a http01 challenge. Things change, however, when the site is internal / behind the vpn. In order to handle the challenge when behind the VPN you need to switch to using a DNS challenge. With ingress this is done by adding the annotation `certmanager.k8s.io/acme-challenge-type: dns`. **Very Important** this assumes you have contacted the ACP beforehand and we have either added the domain to our route53 or added the dns provider as a challenge provider.

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
      ingress.kubernetes.io/backend-protocol: "HTTPS"
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
            servicePort: 10443
          path: /
    tls:
    - hosts:
      - www.example.com
      # @NOTE: this is the name of the kubernetes secret to create in your namespace
      secretName: example-tls
```
A few things to note here; the cert-manager works with the custom resource `Certificate` when using ingress annotation what the cert-manager is doing is using another internal controller to pick up the ingress resources and create a Certificate resource on your behalf. Of course you can instead define this directly yourself.

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
        ingressClass: nginx-external
  commonName: www.example.com
  dnsNames:
  - www.example.com
  issuerRef:
    kind: ClusterIssuer
    # we support letsencrypt-prod and letsencrypt-staging
    name: letsencrypt-prod
  secretName: example-tls
```

You can review, get, list and describe the Certificate like any other kubernetes resource within your namespace.

```shell
$ kubectl -n project get certificate
NAME        AGE
example-tls    1d

# you can also review the order and challenge via
$ kubectl -n project get orders
$ kubectl -n project get challenge
```

**Network Policies**

In order to handle the http01 challenge the requestor is provided an ephermal token which must be handled back to LetsEncrypt on the path `http://domain/.well-known/acme-challenge/`, thus validating to them you own the domain's your requesting for. Cert-manager handles the http01 resolver by;

- creating a order resource within the namespace.
- a controller pick up the order and creates a challenge resource from it, creating an ephermal pod, service and ingress in your namespace and routing the `/.well-known/acme-challenge/`.
- the controller checks the path/s has been provision via the ingress beforehand and validates the order, the certificate controller is then free to inform letsencrypt to call us back.
- it continues to probe the request and once validated, pulls down the certificate.

**IMPORTANT** All this requires the user's to add a network policy to permit the callback, as ACP by default denies all traffic.

```YAML
# This default policy permits access for LetsEncrypt to resolve the http01 challenges from the ACME pods
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: permit-certmanager-acme
spec:
  policyTypes:
  - Ingress
  podSelector:
    matchExpressions:
    - {key: certmanager.k8s.io/acme-http-domain, operator: Exists}
    - {key: certmanager.k8s.io/acme-http-token, operator: Exists}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-external
    - podSelector:
        matchLabels:
          name: ingress
    ports:
    - protocol: TCP
      port: 8089
```

#### **As a developer I want to retrieve a certificate for a service behind the vpn, or simple wish to use the DNS validation**

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
    kind: ClusterIssuer
  commonName: mysite.example.com
  dnsNames:
  - example.com
  acme:
    config:
    - dns01:
        provider: route53
      domains:
      - mysite.example.com
      - example.com
```

Or via ingress you would use

```YAML
apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      certmanager.k8s.io/acme-challenge-type: dns01
      certmanager.k8s.io/acme-dns01-provider: route53
      certmanager.k8s.io/enabled: "true"
      kubernetes.io/ingress.class: nginx-internal
    name: example
  spec:
    rules:
    - host: mysite.example.com
      http:
        paths:
        - backend:
            serviceName: service_name
            servicePort: 443
          path: /
    tls:
    - hosts:
      - mysite.example.com
      - example.com
      secretName: example-tls
```
