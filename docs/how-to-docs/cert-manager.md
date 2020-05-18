# **Cert Manager**

## VERY IMPORTANT upgrade information

`cert-manager` is being upgraded from v0.8 to v0.13.1. If you have cert-manager resources deployed in your namespaces, you MUST follow the [instructions to upgrade from v0.8](cert-manager-upgrade-from-v0.8.md) to upgrade annotations and labels in order for them to be managed by the new version of cert-manager.

To find out if you are using v0.8 cert-manager resources in your namespace, you can run:

```
kubectl get certificates.certmanager.k8s.io
```

Also LetsEncrypt will no longer be supporting PSG's kube-cert-manager from June 2020. So if you are using PSG kube-cert-manager to obtain certificates for your ingresses, you also need to migrate to JetStack's cert-manager v0.13.1 and follow the [instructions to upgrade from PGS's kube-cert-manager](cert-manager-upgrade-from-psg.md)

To find out if you are using PSG kube-cert-manager to manage your ingresses certificates, you can run:

```
kubectl get ingresses -o yaml | grep stable.k8s.psg.io
```

Please also be aware that admission policies have been updated and will reject `Ingress` resources with annotations or labels supported by more than one certificate manager. There are currently ingresses with both cert-manager v0.8 and PSG annotations or labels and those will now fail applying.

## Background

The ACP platform presently has two certificate management services.

The first service was PSG's [kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager). However with the forever changing landscape the project gradually became deprecated and now recommends replacement with JetStack's [cert-manager](https://github.com/jetstack/cert-manager).

Therefore, projects still using kube-cert-manager should modify their services to start using cert-manager instead. Note that ACP will continue to support kube-cert-manager and the internal cfssl service while they are still in use, but we do recommend shifting over to cert-manager as soon as possible as aside from security fixes there will not be any more updates to these services.

Without wishing to duplicate documentation which can be found in the [readme](https://github.com/jetstack/cert-manager/blob/master/README.md) and or official [documentation](https://cert-manager.io/docs/), cert-manager can effectively replace two services:

- kube-cert-manager: used to acquire certificates from LetsEncrypt.
- cfssl: an internal Cloudflare service used to generate internal certificate _(usually to encrypt between ingress and pod)_.

**IMPORTANT NOTE:**

`cert-manager` is being upgraded from v0.8 to v0.13.1. In order to allow development teams to upgrade their `cert-manager` resources according to their own schedule, both v0.8 and v.13.1 resources will be available concurrently for a period of time.

While the older version of `cert-manager` (v0.8) is still available on the ACP platform, resources managed by the newer version of cert-manager (v0.13.1+) can only be accessed from the API server by suffixing the resource kind with `.cert-manager.io`.

For example:

```
# to access v0.13.1 cert-manager resources
kubectl -n project get certificate.cert-manager.io
kubectl -n project get orders.acme.cert-manager.io
kubectl -n project get challenge.acme.cert-manager.io
```

```
# to access v0.8 cert-manager resources
kubectl -n project get certificate
kubectl -n project get orders
kubectl -n project get challenge
# or
kubectl -n project get certificate.certmanager.k8s.io
kubectl -n project get orders.certmanager.k8s.io
kubectl -n project get challenge.certmanager.k8s.io
```

## **How-tos**

### **As a developer I already have a certificate from the legacy kube-cert-manager, how do I migrate?**

Migrating from the former [kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager) over to [cert-manager](https://github.com/jetstack/cert-manager) means creating the certificate request as below and removing the annotations from the ingress. However, the safe way would be to;

- Create a new Certificate resource and point to a **new** secret name _(thus keeping the old one incase)_.
- Push out the change and wait for the certificate to be fulfilled.
- Once you have the certificate you can update your ingress to use the new secret,**remove** the annotations and use the Certificate resource thereafter.

### **As a developer I want to retrieve an internal certificate**

As stated above the cert-manager can also handle internal certificates i.e. those signed by the internal ACP Certificate Authority _(this is self signed btw)_. At the moment you might be using [cfssl-sidekick](https://github.com/UKHomeOffice/cfssl-sidekick) to perform this, but this can be completely replaced.

If you want to create a certificate for a service, assuming the service is called `myservice` in namespace `mynamespace`, the Certificate definition would look like:

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: tls
spec:
  secretName: tls
  issuerRef:
    name: platform-ca
    kind: ClusterIssuer
  dnsNames:
  - myservice
  - myservice.mynamespace
  - myservice.mynamespace.svc
  - myservice.mynamespace.svc.cluster.local
  - localhost
  ipAddresses:
  - 127.0.0.1
```

Ingress resources are checked by admission policies to ensure the platform-ca cluster issuer only issues certificates for DNS names that are hosted inside the namespace.

So if you want to create a certificate for a replica in a statefulset, assuming your statufelset is called `mysts`, the Certificate definition would look like:

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: tls
spec:
  secretName: tls
  issuerRef:
    name: platform-ca
    kind: ClusterIssuer
  dnsNames:
  - mysts-0.myservice.mynamespace
  - mysts-0.myservice.mynamespace.svc
  - mysts-0.myservice.mynamespace.svc.cluster.local
  - localhost
  ipAddresses:
  - 127.0.0.1
```

Note that `mysts-0.myservice` is intentionally missing from the list in `dnsNames` because those names need to be either a hostname (for the service) or a name ending with `mynamespace`, `mynamespace.svc` or `mynamespace.svc.cluster.local`.

This would create a kubernetes secret named `tls` in your namespace with the signed certificate. An interesting thing to note here is that although this is using the ClusterIssuer platform-ca created by the ACP team, there is nothing stopping a project from creating a local Issuer for their own project. So for example.

```YAML
---
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: project-ca
spec:
  ca:
    secretName: project-ca
---
apiVersion: cert-manager.io/v1alpha2
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
  ipAddresses:
  - 127.0.0.1
```

Finally, if you want to use your certificate for client auth (as well as server auth in the following example), you need to add a `keyUsages` section to your Certificate resource:

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: tls
spec:
  secretName: tls
  issuerRef:
    name: platform-ca
    kind: ClusterIssuer
  keyUsages:
  - server auth
  - client auth
  dnsNames:
  - myservice
  - myservice.mynamespace
  - myservice.mynamespace.svc
  - myservice.mynamespace.svc.cluster.local
  - localhost
  ipAddresses:
  - 127.0.0.1
```

### **As a developer I want to retrieve a certificate for my external service**

Let's assume we have an externally facing site which we wish to expose via ingress and we want a valid LetsEncrypt certificate.

Getting a certificate associated with the external ingress only requires to annotate the ingress with `cert-manager.io/enabled`, which is a toggle to ask cert-manager to handle this ingress resource.

Optionally, the acme solver to be used by the cluster issuer can be specified with label `cert-manager.io/solver: http01`. However, this is not required as the `http01` acme solver is the default one.

Please note that `cert-manager.io/enabled` is an annotation but `cert-manager.io/solver` is a label.

When the site is externally facing i.e. the ingress class on the ingress is `kubernetes.io/ingress.class: nginx-external` you should always default to using a http01 challenge. However, if you know that the domain whitelisted in your namespace is hosted in AWS by Route53, you can instead specify a label of `cert-manager.io/solver: route53`

```YAML
apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    annotations:
      # @NOTE: this will enable cert-manager to handle this resource
      cert-manager.io/enabled: "true"
      ingress.kubernetes.io/affinity: cookie
      ingress.kubernetes.io/force-ssl-redirect: "true"
      ingress.kubernetes.io/backend-protocol: "HTTPS"
      ingress.kubernetes.io/session-cookie-name: ingress
      ingress.kubernetes.io/ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx-external
    name: example
  # @NOTE: the following label can be specified to ask letsencrypt to use the http01 acme challenge
  # @NOTE: but it is not required as http01 is the default solver
  labels:
    cert-manager.io/solver: http01

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
      # @NOTE: this is the name of the kubernetes secret that cert-manager will manage in your namespace
      secretName: example-tls
```

A few things to note here:

- behind the scenes, cert-manager works with the `Certificate` custom resource.
- when using ingress annotations and labels, cert-manager uses another internal controller to pick up the ingress resources and create a `Certificate` resource on your behalf. Of course, you can instead define this directly yourself but you will also have to define annotations on the ingress resource to specify which secret should be used for TLS termination. This is the recommended and safest approach when migrating from `kube-cert-manager` to `cert-manager`.

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: example
spec:
  commonName: www.example.com
  dnsNames:
  - www.example.com
  issuerRef:
    kind: ClusterIssuer
    # @Note: we support letsencrypt-prod and letsencrypt-staging (use the latter to test your cert-manager related manifests)
    name: letsencrypt-prod
  secretName: example-tls
```

You can review, get, list and describe the Certificate like any other kubernetes resource within your namespace.

```shell
$ kubectl -n project get certificate
NAME        AGE
example-tls    1d

# you can also review the certificaterequests, orders and challenges via
$ kubectl -n project get orders
$ kubectl -n project get challenge
```

**Network Policies**

Please note that as part of the implementation of cert-manager v0.13.1, a `GlobalNetworkPolicy` object managing ingress traffic for `http01` challenges has been deployed.

This means that you no longer need to have a `NetworkPolicy` in your namespaces allowing ingress traffic from port 8089 to the ephemeral pods that cert-manager creates to handle the `http01` challenge.

### **As a developer I want to retrieve a certificate for a service behind the vpn, or simply wish to use the DNS validation**

When a site is internal / behind the vpn, in order to handle the challenge you need to switch to using a DNS challenge.

This is done by adding the following to your ingress resource:

- annotation `cert-manager.io/enabled: "true"`
- label `cert-manager.io/solver: route53`

**Very Important**: in order to successfully switch to a DNS challenge, please ensure you have contacted the ACP team before attempting this for the first time on your sub-domain as the correct permissions need to exist to permit cert-manager to add records to the domain.

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: example-tls
  labels:
    # @Note: this label tells the cluster issuer to use the DNS01 Route53 solver instead of the default HTTP01 solver
    cert-manager.io/solver: route53
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
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: example
  annotations:
    # @Note: get cert-manager to manage this ingress
    cert-manager.io/enabled: "true"
    kubernetes.io/ingress.class: nginx-internal
  labels:
    # @Note: this label tells the cluster issuer to use the DNS01 Route53 solver instead of the default HTTP01 solver
    cert-manager.io/solver: route53
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

### **As a developer I want to use LetsEncrypt staging while configuring my cert-manager resources**

You should use the staging version of LetsEncrypt in order to not be impacted by rate limits of the production version while setting up and testing the cert-manager annotations and labels you specify on your resources.

By default, the production version of the LetsEncrypt ACME servers is used.

To use the staging version, use the `cert-manager.io/cluster-issuer` annotation:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: example
  annotations:
    cert-manager.io/enabled: "true"
    kubernetes.io/ingress.class: nginx-internal
    # @Note: we are specifying which cluster issuer to use
    cert-manager.io/cluster-issuer: letsencrypt-staging
labels:
    cert-manager.io/solver: route53
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

Not specifying this annotation is equivalent to specifying `cert-manager.io/cluster-issuer: letsencrypt-prod`.

Please note that the certificates issued by the staging version of LetsEncrypt are not signed and should not be used in production.

### **As a developer I want to get a certificate for a server with a DNS name longer than 63 characters**

A certificate's `commonName` is used to create a Certificate Signing Request and populate a field that is limited to 63 characters.

In order to get a certificate for a server with a DNS name longer than 63 characters, you need to specify a common name of less than 63 characters and add the desired DNS name as an additional entry to `dnsNames`.

For example, with an `Ingress`:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: example
  annotations:
    cert-manager.io/enabled: "true"
    kubernetes.io/ingress.class: nginx-internal
  labels:
    cert-manager.io/solver: route53
spec:
  rules:
  - host: my-rather-long-winded-service-name.my-namespace.subdomain.example.com
    http:
      paths:
      - backend:
          serviceName: service_name
          servicePort: 443
        path: /
  tls:
  - hosts:
    - svc-1.my-namespace.subdomain.example.com
    - my-rather-long-winded-service-name.my-namespace.subdomain.example.com
    secretName: example-tls
```

Or with a `Certificate`:

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: example
spec:
  secretName: example-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  commonName: svc-1.my-namespace.subdomain.example.com
  dnsNames:
  - svc-1.my-namespace.subdomain.example.com
  - my-rather-long-winded-service-name.my-namespace.subdomain.example.com
```
