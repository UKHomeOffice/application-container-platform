## **Cert Manager**
----

The ACP platform presently has two certificate management services.

The first service was [kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager). However with the forever changing landscape the project gradually became deprecated and now recommends replacement with [cert-manager](https://github.com/jetstack/cert-manager).

Therefore, projects still using kube-cert-manager should modify their services to start using cert-manager instead. Note that ACP will continue to support kube-cert-manager and the internal cfssl service while they are still in use, but we do recommend shifting over to cert-manager as soon as possible as aside from security fixes there will not be any more updates to these services.

Without wishing to duplicate documentation which can be found in the [readme](https://github.com/jetstack/cert-manager/blob/master/README.md) and or official [documentation](https://cert-manager.io/docs/), cert-manager can effectively replace two services:

- kube-cert-manager: used to acquire certificates from LetsEncrypt.
- cfssl: an internal Cloudflare service used to generate internal certificate _(usually to encrypt between ingress and pod)_.

**IMPORTANT NOTE:**

`cert-manager` is being upgraded from v0.8 to v0.12. In order to allow development teams to upgrade their `cert-manager` resources according to their own schedule, both v0.8 and v.12 resources will be available concurrently for a period of time.

While the older version of `cert-manager` (v0.8) is still available on the ACP platform, resources managed by the newer version of cert-manager (v0.12+) can only be accessed from the API server by suffixing the resource kind with `.cert-manager.io`.

For example:

```
# to access v0.12 cert-manager resources
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

### **How-tos**

#### **As a developer I already have a certificate from the legacy kube-cert-manger, how do I migrate?**

Migrating from the former [kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager) over to [cert-manager](https://github.com/jetstack/cert-manager) means creating the certificate request as below and removing the annotations from the ingress. However, the safe way would be to;

- Create a new Certificate resource and point to a **new** secret name _(thus keeping the old one incase)_.
- Push out the change and wait for the certificate to be fulfilled.
- Once you have the certificate you can update your ingress to use the new secret,**remove** the annotations and use the Certificate resource thereafter.

#### **As a developer I want to retrieve an internal certificate**

As stated above the cert-manager can also handle internal certificates i.e. those signed by the internal ACP Certificate Authority _(this is self signed btw)_. At the moment you might be using [cfssl-sidekick](https://github.com/UKHomeOffice/cfssl-sidekick) to perform this, but this can be completely replaced.

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
  commonName: site.svc.project.cluster.local
  dnsNames:
  - localhost
  - 127.0.0.1
```

This would create a kubernetes secret named `tls` in your namespace with the signed certificate. An interesting thing to note here is that although this is using the ClusterIssuer platform-ca created by the ACP team, there is nothing stopping a project from creating a local Issuer for the own project. So for example.

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
  - 127.0.0.1
```

#### **As a developer I want to retrieve a certificate for my external service**

Let's assume we have an externally facing site which we wish to expose via ingress and we want a valid LetsEncrypt certificate.

Getting a certificate associated with the external ingress only requires to annotate the ingress with `cert-manager.io/enabled`, which is a toggle to ask cert-manager to handle this ingress resource.

Optionally, the acme solver to be used by the cluster issuer can be specified with label `cert-manager.io/solver: http01`. However, this is not required as the `http01` acme solver is the default one.

Please note that `cert-manager.io/enabled` is an annotation but `cert-manager.io/solver` is a label.

When the site is externally facing i.e. the ingress class on the ingress is `kubernetes.io/ingress.class: ingress-external` you should always default to using a http01 challenge.

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

# you can also review the certfificaterequests, orders and challenges via
$ kubectl -n project get orders
$ kubectl -n project get challenge
```

**Network Policies**

In order to handle the http01 challenge the requestor is provided an ephermal token which must be handled back to LetsEncrypt on the path `http://domain/.well-known/acme-challenge/`, thus validating to them you own the domain's your requesting for.

Cert-manager handles the http01 resolver by:

- creating a `CertificateRequest` resource within the namespace
- a controller picks up the certificate request and because the issuer's solver is an acme http01 solver, it creates an acme `Order` within the namespace
- a controller picks up the order and creates a `Challenge` resource from it, creating an ephermal pod, service and ingress in your namespace and routing the `/.well-known/acme-challenge/`.
- the controller checks the path has been provisioned via the ingress beforehand and validates the order.
- the certificate controller then informs letsencrypt to call us back.
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
    - {key: acme.cert-manager.io/http-domain, operator: Exists}
    - {key: acme.cert-manager.io/http-token, operator: Exists}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-external
      podSelector:
        matchLabels:
          name: ingress
    ports:
    - protocol: TCP
      port: 8089
```

#### **As a developer I want to retrieve a certificate for a service behind the vpn, or simply wish to use the DNS validation**

When a site is internal / behind the vpn, in order to handle the challengert you need to switch to using a DNS challenge.

This is done by adding the following to your ingress resource:

- annotation `cert-manager.io/enabled: "true"`
- label `cert-manager.io/solver: route53`

**Very Important**: in order to successfully switch to a DNS challenge, please ensure you have contacted the ACP team before attempting this for the first time on your sub-domain as the correct permissions need to exist to permit cert-manager to add records to the domain.

```YAML
apiVersion: networking.k8s.io/v1beta1
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

#### **As a developer I want to use LetsEncrypt staging while configuring my cert-manager resources**

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

#### **As a developer I want to get a certificate for a server with a DNS name longer than 63 characters**

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

#### **As a developer I want to migrate my cert-manager resources from v0.8 to v.11+**

**IMPORTANT - PLEASE READ.**

**In version v0.11, cert-manager has introduced some backwards incompatible changes that were announced in v0.8.**

**Because there are currently 2 instances of cert-manager running on the ACP platform, it is important that your cert-manager related resources are only managed by one of those instances. Otherwise, you run the risk of hitting letsencrypt rate limits as the 2 instances of cert-manager both attempt to manage the same resources.**

**In order to do that, you must de-register your resources with the current version of cert-manager (v0.8) before getting registered with the new version of cert-manager (v0.11+).**

The following official cert-manager documentation provides good background information as to what has changed.

- [v0.8 Release Notes](https://cert-manager.io/docs/release-notes/release-notes-0.8/)
- [v0.11 Release Notes](https://cert-manager.io/docs/release-notes/release-notes-0.11/)
- [Upgrading from v0.7 to v0.8](https://cert-manager.io/docs/installation/upgrading/upgrading-0.7-0.8/)
- [Upgrading from v0.10 to v0.11](https://cert-manager.io/docs/installation/upgrading/upgrading-0.10-0.11/)

Essentially, the cert-manager API version has been changed from `certmanager.k8s.io/v1alpha1` to `cert-manager.io/v1alpha2`. This means that both `Ingress` and `Certificate` resources have to be changed: there are annotations and labels changes for both resource types, as well as structural changes for `Certificate`s.

##### Step 1 - de-registering resources from v0.8

- Update all your ingress resources and remove ***all*** `certmanager.k8s.io` annotations.
- Deploy your ingress changes
- Delete all your `Certificate` resources. You might want to back them up before doing that.
- Wait a minute or so and verify that the certificate resources have not been re-created with `kubectl get certificates -n my-namespace`. If a certificate is re-cretated, double-check your ingress annotations.

Note that:

1) All `Certificate` resources should be deleted: the ones managed by the ingress shim controller and the ones for which you have `Certificate` manifests.
2) Although the certificate resources have been deleted, this will not affect the secrets containing the TLS private key and signed certificate. That's because, by default, cert-manager does not delete the secrets specified in a certificate object when that certificate object is deleted. This means that your service will continue having a valid certificate until it expires, so you have some time (usually at least 4 weeks) to complete the migration.

An example of removing the annotations can be found in [kube-example-app](https://github.com/UKHomeOffice/kube-example-app/commit/a161ea22563e45fcd87141933118d2102caa4dc1).

##### Step 2 - updating the resources for v0.11+

The following examples are based on the [kube-example](https://github.com/ukhomeoffice/kube-example-app) project.

An example of updating annotations and labels can be found in [kube-example-app](https://github.com/UKHomeOffice/kube-example-app/commit/379a6da037a91089726bd0b335db87a3e723208e) but they are also explained below.

###### External Ingress changes

Changes required for websites or services exposed externally

The following `Ingress` resource with v0.8 annotations:

```YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external
  annotations:
    certmanager.k8s.io/acme-challenge-type: "http01"
    certmanager.k8s.io/enabled: "true"
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-external"
spec:
  rules:
  - host: {{ .APP_HOST_EXTERNAL }}
    http:
      paths:
      - backend:
          serviceName: {{ .DEPLOYMENT_NAME }}
          servicePort: 10443
        path: /
  tls:
  - hosts:
    - {{ .APP_HOST_EXTERNAL }}
    secretName: {{ .DEPLOYMENT_NAME }}-external-tls
```

should be changed to `Ingress` resource with the following v0.11 annotations:

```YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external
  annotations:
    # @Note: get rid of any certmanager.k8s.io annotations
    # @Note: change the enabled annotation to cert-manager.io/enabled
    cert-manager.io/enabled: "true"
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-external"
spec:
  rules:
  - host: {{ .APP_HOST_EXTERNAL }}
    http:
      paths:
      - backend:
          serviceName: {{ .DEPLOYMENT_NAME }}
          servicePort: 10443
        path: /
  tls:
  - hosts:
    - {{ .APP_HOST_EXTERNAL }}
    secretName: {{ .DEPLOYMENT_NAME }}-external-tls
```

###### Internal Ingress changes

Changes required for websites or services exposed internally

The following `Ingress` resource with v0.8 annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-internal
  annotations:
    certmanager.k8s.io/acme-challenge-type: "dns01"
    certmanager.k8s.io/enabled: "true"
    certmanager.k8s.io/acme-dns01-provider: "route53"
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-internal"
spec:
  rules:
  - host: {{ .APP_HOST_INTERNAL }}
    http:
      paths:
      - backend:
          serviceName: {{ .DEPLOYMENT_NAME }}
          servicePort: 10443
        path: /
  tls:
  - hosts:
    - {{ .APP_HOST_INTERNAL }}
    secretName: {{ .DEPLOYMENT_NAME }}-internal-tls
```

should be changed to `Ingress` resource with the following v0.11 annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-internal
  annotations:
    # @Note: get rid of any certmanager.k8s.io annotations
    # @Note: change the enabled annotation to cert-manager.io/enabled
    cert-manager.io/enabled: "true"
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-internal"
  # @Note: add label cert-manager.io/solver to specify that the route53 dns01 solver should be used
  labels:
    cert-manager.io/solver: route53
spec:
  rules:
  - host: {{ .APP_HOST_INTERNAL }}
    http:
      paths:
      - backend:
          serviceName: {{ .DEPLOYMENT_NAME }}
          servicePort: 10443
        path: /
  tls:
  - hosts:
    - {{ .APP_HOST_INTERNAL }}
    secretName: {{ .DEPLOYMENT_NAME }}-internal-tls
```

###### Certificate resources changes

Please note that because the apiGroup for the new certificate resource (`cert-manager.io`) is different from the old one (`certmanager.k8s.io`), by making the changes below to your `Certificate` resource, you will actually create a new `Certificate` object as opposed to replacing the existing one.

The following v0.8 `Certificate` resource providing a self-signed certificate:

```YAML
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: {{ .DEPLOYMENT_NAME }}-service-tls
spec:
  secretName: {{ .DEPLOYMENT_NAME }}-service-tls
  issuerRef:
    name: platform-tls
    kind: ClusterIssuer
  commonName: app.{{ .KUBE_NAMESPACE }}.svc.cluster.local
  dnsNames:
  - app
  - app.{{ .KUBE_NAMESPACE }}.svc
```

should be changed to a v0.11 `Certificate`

```YAML
# @Note: change the apiVersion
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: {{ .DEPLOYMENT_NAME }}-service-tls
spec:
  secretName: {{ .DEPLOYMENT_NAME }}-service-tls
  issuerRef:
    # @Note: change the name of the issuer
    name: platform-ca
    kind: ClusterIssuer
  commonName: app.{{ .KUBE_NAMESPACE }}.svc.cluster.local
  dnsNames:
  - app
  - app.{{ .KUBE_NAMESPACE }}.svc
```

In order to convert a `Certificate` resource for a certificate issued by LetsEncrypt, the `spec.issuerRef.name` should be set as `letsencrypt-prod`.

For an externally accessed service, no labelling is required.

However for an internally accessed service whose certificate ACME challenge is resolved with dns01, the following label should be added: `cert-manager.io/solver: route53`.

###### Network Policy resources changes

The following `NetworkPolicy` resource with v0.8 match expressions:

```YAML
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
    ports:
    - protocol: TCP
      port: 8089
```

should be changed to `NetworkPolicy` resource with the following v0.11 match expressions:

```YAML
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: permit-certmanager-acme
spec:
  policyTypes:
  - Ingress
  podSelector:
    matchExpressions:
    # @Note: both match expressions have changed
    - {key: acme.cert-manager.io/http-domain, operator: Exists}
    - {key: acme.cert-manager.io/http-token, operator: Exists}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-external
      podSelector:
        matchLabels:
          name: ingress
    ports:
    - protocol: TCP
      port: 8089
```

###### Deployment verification

Once you have applied the changes above, you should no longer have `Certificate` resources managed by v0.8.

To verify that's the case, run `kubectl get certificate -n my-namespace`. The resource list returned should be empty.

To verify that the new version of cert-manager is managing the certificates, run `kubectl get certificate.cert-manager.io -n my-namespace`. An non-empty list of resources should be returned, including any certificate resources you have created yourselves as well as ones created by cert-manager on behalf of an ingress.

Once the development teams have migrated all their resources to the new version of cert-manager, the old instance will be decommissioned. When that's done it will no longer be needed to append `.cert-manager.io` to the resource kinds when using `kubectl`.
