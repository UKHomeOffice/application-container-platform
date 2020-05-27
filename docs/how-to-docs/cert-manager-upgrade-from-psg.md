# Migration from PSG kube-cert-manager resources to Jetstack cert-manager v0.13.1

## Table of Content

1. [Background (understanding why a migration is needed)](#background-understanding-why-a-migration-is-needed)
1. [Migration options](#migration-options)
    1. [Option 1 (renaming secrets)](#option-1-renaming-secrets)
    1. [Option 2 (explicit ingress certificate)](#option-2-explicit-ingress-certificate)
1. [Getting cert-manager resources](#getting-cert-manager-resources)
1. [Updating cert-manager resources for v0.13.1](#updating-cert-manager-resources-for-v0131)
    1. [Option 1 changes (simplest)](#option-1-changes-simplest)
        1. [External Ingress with DNS challenge changes (simplest)](#external-ingress-with-dns-challenge-changes-simplest)
        1. [External Ingress with HTTP challenge changes (simplest)](#external-ingress-with-http-challenge-changes-simplest)
        1. [Internal Ingress with DNS challenge changes (simplest)](#internal-ingress-with-dns-challenge-changes-simplest)
    1. [Option 2 changes](#option-2-changes)
        1. [External Ingress with DNS challenge changes (safest with 2 stages)](#external-ingress-with-dns-challenge-changes-safest-with-2-stages)
        1. [External Ingress with HTTP challenge changes (safest with 2 stages)](#external-ingress-with-http-challenge-changes-safest-with-2-stages)
        1. [Internal Ingress with DNS challenge changes (safest with 2 stages)](#internal-ingress-with-dns-challenge-changes-safest-with-2-stages)
    1. [Deployment verification](#deployment-verification)

## Background (understanding why a migration is needed)

[PalmStoneGames/kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager) has been deprecated and not updated for 2 years, but more importantly it will stop being supported by LetsEncrypt in June 2020.

Please note that although cert-manager v0.13.1 was initially deployed, it quickly had to be replaced with a deployment of v0.15.0 because of [No configured Challenge Solvers for ACME Prod only](https://github.com/jetstack/cert-manager/issues/2494).

cert-manager v0.13.1 supports the `cert-manager.io/v1alpha2` API version whereas v0.15.0 supports both `cert-manager.io/v1alpha2` and `cert-manager.io/v1alpha3`. v0.15.0 converts the v1alpha2 objects to v1alpha3, so although technically `cert-manager.io/v1alpha3` is specified as the `apiVersion` for `Certificate` objects, it will also work with `cert-manager.io/v1alpha2`

## Migration options

There are 2 possible approaches for the migration of `Ingress` resources. The high-level steps for both approaches are expanded below.

For a more detailed understanding of how the manifest files need to be updated, please refer to section [Updating cert-manager resources for v0.13.1](#updating-cert-manager-resources-for-v0131) below.

Option 1 is the simplest and is appropriate if you can afford some down-time (typically a couple of minutes, but longer if there is an issue).

If you have to minimise disruption to users, option 2 is likely more appropriate.

### Option 1 (renaming secrets)

The simplest option is to amend the annotations and labels of your `Ingress` resources as described below **while at the same time also renaming the associated secrets**.

Renaming the secret (changing the value of `secretName` in your `Ingress` resource) will make sure that the same secret is not managed by 2 certificate managers (PSG kube-cert-manager and JetStack's cert-manager v0.13.1).

To keep names consistent, you could for example add a `-cmio` suffix  (standing for `cert-manager.io`) to all the `secretName` attributes in the `Ingress` resources as shown below in the example section.

- Amend `Ingress` resources:
  - amend the `Ingress`'s annotations and labels as described below
  - change the value of `secretName`
- Deploy the changes
- When you've checked that the service is functioning as intended, you can tidy up the old secrets that used to be managed by PSG kube-cert-manager:
  - delete any secrets that was previously associated with the `Ingress` (back them up to be safe)
- You can check that the certificate resources automatically created by cert-manager thanks to your ingress annotations are valid by running `kubectl -n project get certificate.cert-manager.io`. The `READY` field for the resources should be `TRUE`. Note that it might take a short while (typically no more than about a couple of minutes) for the certificates to reach that `READY` state.

The main draw-back of this approach is that the value for the new secret being created will need to be created from LetsEncrypt. This is usually quite quick, but could take up to around 2 minutes.

During the time the new certificate is being requested and LetsEncrypt performs its http or dns challenge, your ingress will not have a valid certificate.
So access to the endpoint is disrupted for that period whilst the challenge is being completed and new cert/secret generated.

Note that if there is an issue obtaining certificates from LetsEncrypt (e.g. due to a rate limit), you might have to roll back the change and carry on using the previous certificates for a while longer. This is typically very rare, but can occur for example due to rate limits or in instances where DNS is set up differently in prod from notprod.

If you are keen on minimising service disruption further and only have current connections reset, please evaluate Option 2 below.

### Option 2 (explicit ingress certificate)

This option is more complex than Option 1 and should only be considered if there are concerens with service availability while ingresses do not have a valid certificate during the initial new certificate request.

If not performed properly (i.e. if you do a single deployment instead of two as described in this section), you will gain nothing from it and it will have the same impact as Option 1.

The high levels steps are:

- Leave the current `Ingress` resource as it is (whith the PSG annotations)
- Create a `Certificate` resource with `letsencrypt-prod` as the clusterIssuer, a secret name different from the one used by the Ingress and the appropriate stanzas as shown later on this guide. You might want to use the `letsencrypt-staging` clusterIssuer instead of `letsencrypt-prod` while changing your Certificate manifest file and testing it in order to not reach the weekly limits imposed by LetsEncrypt on its prod server and switch to `letsencrypt-prod` once you know your `Certificate` resource works as you expect.
- Deploy the changes to create the new `Certificate` resource. Please note that the certificate and associated secret will at that point be unused, but make sure the `Certificate` is ready before deploying the next set of changes. You can check that by running `kubectl get certificates.cert-manager.io` in your namespace.
- Update your `Ingress` resources
  - Remove all `stable.k8s.psg.io` annotations and labels
  - *DO NOT* add any new `cert-manager.io` annotations or labels
  - Update `secretName` in the `Ingress` resource to the name of the secret you created in step 2 (the secret associated with your `Certficate` resource)
- Deploy the `Ingress` changes
- When you've checked that the service is functioning as intended and that its certificate has been updated, you can tidy up the old secrets:
  - delete any secrets previously associated with the ingress (back them up to be safe)
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

### Option 1 changes (simplest)

#### External Ingress with DNS challenge changes (simplest)

Changes required for websites or services exposed externally with ACME DNS challenge suitable when your domain is hosted as a Route53 zone.

The following `Ingress` resource with PSG labels and annotations

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external
  annotations:
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-external"
    # @Note: your ingress might not specify stable.k8s.psg.io/kcm.provider as dns is the default provider
    stable.k8s.psg.io/kcm.provider: dns
  labels:
    stable.k8s.psg.io/kcm.class: default
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
    # @Note: get rid of any psg annotations
    # @Note: make sure you DON'T have the following annotation: kubernetes.io/tls-acme: "true"
    # @Note: add the enabled annotation to cert-manager.io/enabled
    cert-manager.io/enabled: "true"
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-external"
  labels:
    # @Note: remove any psg labels you might have
    # @Note: add label cert-manager.io/solver to specify that the route53 dns01 solver should be used
    cert-manager.io/solver: route53
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

#### External Ingress with HTTP challenge changes (simplest)

Changes required for websites or services exposed externally with ACME HTTP challenge

The following `Ingress` resource with PSG labels and annotations

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external
  annotations:
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-external"
    stable.k8s.psg.io/kcm.provider: http
  labels:
    stable.k8s.psg.io/kcm.class: default
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
    # @Note: get rid of any psg annotations
    # @Note: add the enabled annotation to cert-manager.io/enabled
    cert-manager.io/enabled: "true"
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-external"
  labels:
    # @Note: remove any psg labels you might have
    # @Note: add label cert-manager.io/solver to specify that the http01 solver should be used
    # @Note: the label below is actually optional because http01 the default value
    cert-manager.io/solver: http01
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

#### Internal Ingress with DNS challenge changes (simplest)

Changes required for websites or services exposed internally with ACME DNS challenge suitable when your domain is hosted as a Route53 zone.

The following `Ingress` resource with PSG labels and annotations

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-internal
  annotations:
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-internal"
    # @Note: your ingress might not specify stable.k8s.psg.io/kcm.provider as dns is the default provider
    stable.k8s.psg.io/kcm.provider: dns
  labels:
    stable.k8s.psg.io/kcm.class: default
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
    # @Note: get rid of any psg annotations
    # @Note: make sure you DON'T have the following annotation: kubernetes.io/tls-acme: "true"
    # @Note: add the enabled annotation to cert-manager.io/enabled
    cert-manager.io/enabled: "true"
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-internal"
  labels:
    # @Note: remove any psg labels you might have
    # @Note: add label cert-manager.io/solver to specify that the route53 dns01 solver should be used
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

#### External Ingress with DNS challenge changes (safest with 2 stages)

Changes required for websites or services exposed externally with ACME DNS challenge suitable when your domain is hosted as a Route53 zone.

The following `Ingress` resource with PSG annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external
  annotations:
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-external"
    # @Note: your ingress might not specify stable.k8s.psg.io/kcm.provider as dns is the default provider
    stable.k8s.psg.io/kcm.provider: dns
  labels:
    stable.k8s.psg.io/kcm.class: default
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
apiVersion: cert-manager.io/v1alpha3
kind: Certificate
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external-tls-cmio
  labels:
    # @Note: specify label cert-manager.io/solver to specify that the route53 dns01 solver should be used
    cert-manager.io/solver: route53
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
    # @Note: get rid of any psg annotations
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

#### External Ingress with HTTP challenge changes (safest with 2 stages)

Changes required for websites or services exposed externally

The following `Ingress` resource with PSG annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external
  annotations:
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-external"
    stable.k8s.psg.io/kcm.provider: http
  labels:
    stable.k8s.psg.io/kcm.class: default
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
apiVersion: cert-manager.io/v1alpha3
kind: Certificate
metadata:
  name: {{ .DEPLOYMENT_NAME }}-external-tls-cmio
  labels:
    # @Note: specify label cert-manager.io/solver to specify that the http01 solver should be used
    # @Note: alternatively, specify no cert-manager.io/solver label as http01 is the default
    cert-manager.io/solver: http01
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
    # @Note: get rid of any psg annotations
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

#### Internal Ingress with DNS challenge changes (safest with 2 stages)

Changes required for websites or services exposed internally with ACME DNS challenge suitable when your domain is hosted as a Route53 zone.

The following `Ingress` resource with PSG annotations:

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ .DEPLOYMENT_NAME }}-internal
  annotations:
    ingress.kubernetes.io/backend-protocol: "HTTPS"
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "nginx-internal"
    # @Note: your ingress might not specify stable.k8s.psg.io/kcm.provider as dns is the default provider
    stable.k8s.psg.io/kcm.provider: dns
  labels:
    stable.k8s.psg.io/kcm.class: default
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
apiVersion: cert-manager.io/v1alpha3
kind: Certificate
metadata:
  name: {{ .DEPLOYMENT_NAME }}-internal-tls-cmio
  labels:
    # @Note: specify label cert-manager.io/solver to specify that the route53 dns01 solver should be used
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
    # @Note: get rid of any psg annotations
    # @Note: no cert-manager.io annotations or labels are added
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

### Deployment verification

Once you have applied the changes above, you should no longer have `Ingress` resources managed by PSG kube-cert-manager.

To verify that's the case, run `kubectl get ingresses -o yaml | grep stable.k8s.psg.io`. An empty list should be returned.

To verify that the new version of cert-manager is managing the certificates, run `kubectl get certificate.cert-manager.io -n my-namespace`. An non-empty list of resources should be returned. Those are the `Certificate` resources which have been created by cert-manager's ingress shim.

Once the development teams have migrated all their resources to the new version of cert-manager, the PSG kube-cert-manager and cert-manager v0.8 will be decommissioned.

When that's done it will no longer be needed to append `.cert-manager.io` to the resource kinds when using `kubectl`.
