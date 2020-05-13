# Migration from Jetstack cert-manager v0.8 resources to v0.13.1

## Table of Content

1. [Background (understanding why a migration is needed)](#background-understanding-why-a-migration-is-needed)
1. [Migration options](#migration-options)
    1. [Option 1 (renaming secrets)](#option-1-renaming-secrets)
    1. [Option 2 (explicit ingress certificate)](#option-2-explicit-ingress-certificate)
1. [Getting cert-manager resources](#getting-cert-manager-resources)
1. [Updating cert-manager resources for v0.13.1](#updating-cert-manager-resources-for-v0131)
    1. [Option 1 changes (recommended)](#option-1-changes-recommended)
        1. [External Ingress changes (recommended)](#external-ingress-changes-recommended)
        1. [Internal Ingress changes (recommended)](#internal-ingress-changes-recommended)
    1. [Option 2 changes](#option-2-changes)
        1. [External Ingress changes (2 stages)](#external-ingress-changes-2-stages)
        1. [Internal Ingress changes (2 stages)](#internal-ingress-changes-2-stages)
    1. [Certificate resources changes](#certificate-resources-changes)
    1. [Network Policy resources changes](#network-policy-resources-changes)
    1. [Deployment verification](#deployment-verification)

There is a lot of information in this migration guide, so please make sure you read it all and understand what is required before performing a migration, as it might have an adverse impact on services if not performed appropriately.

## Background (understanding why a migration is needed)

**In version v0.11, cert-manager introduced some backwards incompatible changes that were announced in v0.8.**

**Because there are currently 2 instances of cert-manager running on the ACP platform, it is important that your cert-manager related resources are only managed by one of those instances. Otherwise, you run the risk of hitting letsencrypt rate limits as the 2 instances of cert-manager both attempt to manage the same resources.**

**See the Migration Options section below to determine which one is most appropriate to you**

The following official cert-manager documentation provides good background information as to what has changed.

- [v0.8 Release Notes](https://cert-manager.io/docs/release-notes/release-notes-0.8/)
- [v0.11 Release Notes](https://cert-manager.io/docs/release-notes/release-notes-0.11/)
- [Upgrading from v0.7 to v0.8](https://cert-manager.io/docs/installation/upgrading/upgrading-0.7-0.8/)
- [Upgrading from v0.10 to v0.11](https://cert-manager.io/docs/installation/upgrading/upgrading-0.10-0.11/)

Essentially, the cert-manager API version has been changed from `certmanager.k8s.io/v1alpha1` to `cert-manager.io/v1alpha2`. This means that both `Ingress` and `Certificate` resources have to be changed: there are annotations and labels changes for both resource types, as well as structural changes for `Certificate`s.

Please note that when updating annotations and labels, you should only do that on resources you have created yourselves (not the ones managed automatically by cert-manager).

For example, if you your manifest file contains a `Certificate` resource definition to terminate TLS on a sidecar, you should update annotations and labels as described below.

However, please be aware that when annotating an `Ingress` resource with cert-manager annotations, cert-manager will automatically create a `Certificate` resource to handle certificate resources to LetsEncrypt. Those `Certificate` resources, which have the same name as the secret name specified in the `Ingress`, are internally managed by cert-manager should not be modified.

## Migration options

There are 2 possible approaches for the migration of resources. The high-level steps for both approaches are expanded below.

For a more detailed understanding of how the manifest files need to be updated, please refer to section [Updating cert-manager resources for v0.13.1](#updating-cert-manager-resources-for-v0131) below.

Option 1 below is strongly recommended as the approach.

### Option 1 (renaming secrets)

By far the easiest and safest option is to amend the annotations and labels as described below **while at the same time also renaming the associated secrets**.

Renaming the secret (changing the value of `secretName` in either `Ingress` or `Certificate` resources) will make sure that the same secret is not managed by 2 `Certificate` resources (the v0.8 certificate and its v0.13.1 counter-part) - whether those `Certificate` resources are part of your deployments or it's one of the resources managed automatically for you by cert-manager when it deals with `Ingress` annotations.

To keep names consistent, you could for example add a `-cmio` suffix  (standing for `cert-manager.io`) to all the `secretName` attributes in the `Ingress` or `Certificate` resources as shown below in the example section.

- For `Ingress` resources:
  - amend the `Ingress`'s annotations and labels as described below
  - change the value of `secretName`
- For `Certificate` resources that are part of your deployments (e.g. to create a certificate that is mounted by an nginx sidecar for your main service):
  - amend the `Certificate`'s annotations and labels
  - change the value of `secretName`
  - amend your deployment to mount the new secret (e.g. get the nginx sidecar to mount the new tls secret)
- Deploy the changes
- When you've checked that the service is functioning as intended, you can tidy up the old v0.8 cert-manager resources:
  - delete any certificate resources still returned by `kubectl -n project get certificate` (back them up if they are not stored in git)
  - delete any secrets associated with those old resources (again, back them up to be safe)
- You can check that the certificate resources are valid by running `kubectl -n project get certificate.cert-manager.io`. The `READY` field for the resources should be `TRUE`. Note that it might take a short while (typically no more than about a couple of minutes) for the certificates to reach that `READY` state.

The main draw-back of this approach is that the value for the new secret being created will need to be created from LetsEncrypt (unless using the platform cluster issuer). This is usually quite quick, but could take up to around 2 minutes.

During the time the new certificate is being requested and LetsEncrypt performs its http or dns challenge, your ingress will not have a valid certificate.
So access to the endpoint is disrupted for that period whilst the challenge is being completed and new cert/secret generated.

If you are keen on minimising service disruption further and only have current connections reset, please evaluate Option 2 below.

### Option 2 (explicit ingress certificate)

This option is more complex than Option 1 and should only be considered if there are concerns with service availability while ingresses do not have a valid certifcate during the initial new certificate request.

If not performed properly, you will gain nothing from it and it will have the same impact as Option 1.

The high levels steps are:

- Leave the current `Ingress` resource as it is (whith old v0.8 annotations)
- Create a `Certificate` resource with `letsencrypt-prod` as the clusterIssuer, a secret name different from the one used by the Ingress and the appropriate stanzas as shown later on this guide. You might want to use the `letsencrypt-staging` clusterIssuer instead of `letsencrypt-prod` while changing your Certificate manifest file and testing it in order to not reach the weekly limits imposed by LetsEncrypt on its prod server and switch to `letsencrypt-prod` once you know your `Certificate` resource works as you expect.
- Deploy the changes to create the new certificate resource. Please note that the certificate and associated secret will at that point be unused, but make sure the `Certificate` is ready before deploying the next set of changes. You can check that by running `kubectl get certificates.cert-manager.io` in your namespace.
- Update your `Ingress` resources
  - Remove all `certmanager.k8s.io` annotations
  - *DO NOT* add any new `cert-manager.io` annotations or labels
  - Update `secretName` in the `Ingress` resource to the name of the secret you created in step 2 (the secret associated with your `Certficate` resource)
- Deploy the `Ingress` changes
- When you've checked that the service is functioning as intended and that its certificate has been updated, you can tidy up the old v0.8 cert-manager resources and secrets:
  - delete any certificate resources still returned by `kubectl -n project get certificates.certmanager.k8s.io` (back them up if they are not stored in git)
  - delete any secrets associated with those old resources (again, back them up to be safe)
- You can check that the certificate resources are valid by running `kubectl -n project get certificates.cert-manager.io`. The `READY` field for the resources should be `TRUE`. Note that it might take a short while (typically no more than about a couple of minutes) for the certificates to reach that `READY` state.

Please note that during the development lifecycle, you will quite naturally deploy the 2 changes above when they are made in 2 separate commit points.

However, when it comes to deploying to other environments once the commits already exist, make sure to deploy the commit associated with the first step (`Certificate` creation), wait for the `Certificate` resource to be ready and only deploy the change to the ingress once it is. If you do not wait and deploy those changes in quick succession, the outcome will be the same as for option 1: your service will be unavailable as it will not have a valid certificate until letsencrypt returns a new one.

## Getting cert-manager resources

As `cert-manager` is being upgraded from v0.8 to v0.13.1 and in order to allow development teams to upgrade their `cert-manager` resources according to their own schedule, both v0.8 and v.13.1 resources will be available concurrently for a period of time.

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

## Updating cert-manager resources for v0.13.1

The following examples are based on the [kube-example](https://github.com/ukhomeoffice/kube-example-app) project.

### Option 1 changes (recommended)

#### External Ingress changes (recommended)

Changes required for websites or services exposed externally

The following `Ingress` resource with v0.8 annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
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

should be changed to `Ingress` resource with the following v0.11+ annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
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
    # @Note: change the secret name
    secretName: {{ .DEPLOYMENT_NAME }}-external-tls-cmio
```

#### Internal Ingress changes (recommended)

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

should be changed to `Ingress` resource with the following v0.11+ annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-internal
  annotations:
    # @Note: get rid of any certmanager.k8s.io annotations
    # @Note: make sure you DON'T have the following annotation: kubernetes.io/tls-acme: "true"
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
    # @Note: change the secret name
    secretName: {{ .DEPLOYMENT_NAME }}-internal-tls-cmio
```

### Option 2 changes

#### External Ingress changes (2 stages)

Changes required for websites or services exposed externally

The following `Ingress` resource with v0.8 annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
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

should be initially left unchanged.

Deploy a new certificate

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external-tls-cmio
spec:
  secretName: {{ .DEPLOYMENT_NAME }}-external-tls-cmio
  issuerRef:
    # use letsencrypt-staging while developing and testing your certificates
    name: letsencrypt-prod
    kind: ClusterIssuer
    group: cert-manager.io
  dnsNames:
  - {{ .APP_HOST_EXTERNAL }}
```

Once the certificate is ready (run `kubectl get certificates.cert-manager.io` to find out its state), change and deploy the `Ingress` resource to specify the new secret name:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external
  annotations:
    # @Note: get rid of any certmanager.k8s.io annotations
    # @Note: no cert-manager.io annotations or labels are added
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
    # @Note: change the secret name
    secretName: {{ .DEPLOYMENT_NAME }}-external-tls-cmio
```

#### Internal Ingress changes (2 stages)

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

should be initially left unchanged.

Deploy a new certificate

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: {{ .DEPLOYMENT_NAME }}-internal-tls-cmio
  labels:
    cert-manager.io/solver: route53
spec:
  secretName: {{ .DEPLOYMENT_NAME }}-internal-tls-cmio
  issuerRef:
    # use letsencrypt-staging while developing and testing your certificates
    name: letsencrypt-prod
    kind: ClusterIssuer
    group: cert-manager.io
  dnsNames:
  - {{ .APP_HOST_INTERNAL }}
```

Once the certificate is ready (run `kubectl get certificates.cert-manager.io` to find out its state), change and deploy the `Ingress` resource to specify the new secret name:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-internal
  annotations:
    # @Note: get rid of any certmanager.k8s.io annotations
    # @Note: no cert-manager.io annotations or labels are added
    cert-manager.io/enabled: "true"
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
    # @Note: change the secret name
    secretName: {{ .DEPLOYMENT_NAME }}-internal-tls-cmio
```

### Certificate resources changes

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
  # @Note: change the secret name
  secretName: {{ .DEPLOYMENT_NAME }}-service-tls-cmio
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

### Network Policy resources changes

The following `NetworkPolicy` resources used to be required to allow successful `http01` ACME challenges for cert-manager v0.8 resources.

This is no longer needed thanks to a new `GlobalNetworkPolicy` which has a cluster-wide scope.

Network policies such as the following in your namespaces can therefore be deleted

```YAML
# No longer required; this NetworkPolicy can now be deleted
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

### Deployment verification

Once you have applied the changes above, you should no longer have `Certificate` resources managed by v0.8.

To verify that's the case, run `kubectl get certificate -n my-namespace`. The resource list returned should be empty.

To verify that the new version of cert-manager is managing the certificates, run `kubectl get certificate.cert-manager.io -n my-namespace`. An non-empty list of resources should be returned, including any certificate resources you have created yourselves as well as ones created by cert-manager on behalf of an ingress.

Once the development teams have migrated all their resources to the new version of cert-manager, the old instance will be decommissioned. When that's done it will no longer be needed to append `.cert-manager.io` to the resource kinds when using `kubectl`.
