# Migration from Jetstack cert-manager v0.8 resources to v0.13.1

There is a lot of information in this migration guide, so please make sure you read it all and understand what is required before performing a migration, as it might have an adverse impact on services if not performed appropriately.

## Background - understanding why a migration is needed

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

For a more detailed understanding of how the manifest files need to be updated, please refer to section `Updating cert-manager resources for v0.13.1` below.

Option 1 below is strongly recommended as the approach.

### Option 1 - renaming secrets

By far the easiest and safest option is to amend the annotations and labels as described below **while at the same time also renaming the associated secrets**.

Renaming the secret (changing the value of `secretName` in either `Ingress` or `Certificate` resources) will make sure that the same secret is not managed by 2 `Certificate` resources (the v0.8 certificate and its v0.13.1 counter-part) - whether those `Certificate` resources are part of your deployments or it's one of the resources managed automatically for you by cert-manager when it deals with `Ingress` annotations.

To keep names consistent, you could for example add a `-cmio` suffix to all secret names (for `cert-manager.io`).

- For `Ingress` resources:
  - amend the `Ingress`'s annotations and labels
  - change the value of `secretName`
- For `Certificate` resources that are part of your deployments (e.g. to create a certificate that is mounted by an nginx sidecar for your main service):
  - amend the `Certificate`'s annotations and labels
  - change the value of `secretName`
  - amend your deployment to mount the new secret (e.g. get the nginx sidecar to mount the new tls secret)
- Deploy the changes
- When you've checked that the service is functioning as intended, you can tidy up the old v0.8 cert-manager resources:
  - delete any certificate resources still returned by `kubectl -n project get certificate` (back them up if they are not stored in git)
  - delete any secrets associated with those old resources (again, back them up to be safe)
- You can check that the certificate resources are valid by running `kubectl -n project get certificate.cert-manager.io`. The `READY` field for the resources should be `TRUE`. Note that it might take a short while (typically no more than about a minute) for the certificates to reach that `READY` state.

The main draw-back of this approach is that the value for the new secret being created will need to be created from LetsEncrypt (unless using the platform cluster issuer). This is usually quite quick, but could take up to around 2 minutes.

During the time the new certificate is being requested and LetsEncrypt performs its http or dns challenge, your ingress will not have a valid certificate.
So access to the endpoint is disrupted for that brief period of time whilst the challenge is being completed and new cert/secret generated.

### Option 2 - keeping same secret names

This option is much more complex than the option 1 and should only be considered if there are concerens with service availability. For example, if there is a single replica and a deployment would create an unacceptable service outage while a new certificate is retrieved. But then again, you're not running services with a single replica as that's a bad pattern, right?

Please be aware that if not performed appropriately, this upgrade path has the potential to hit LetsEncrypt limits and therefore prevent new certificates to be successfully retrieved for a given hostname for up to a week.

- For `Ingress` resources:
  - amend the `Ingress`'s annotations and labels to **REMOVE** all `certmanager.k8s.io` annotations. **DO NOT** add any of the new cert-manager annotations yet.
- Deploy the ingress changes. This will unregister the ingresses from the old version of cert-manager and within a few minutes, the `Certificate` resources that cert-manager created automatically will be deleted. The secrets with the tls private key and certificate will still be available and therefore your ingress will carry on working until that certificate expires. That's because, by default, cert-manager does not delete the secrets specified in a certificate object when that certificate object is deleted. You typically have several weeks during which the certifcate will remain valid.
- Delete all remaining `Certificate` resources returned by `kubectl -n project get certificate`. At this stage, assuming that you have waited long enough for the unregistering of `Ingress` resources to occur, you should only see certificate resources for which you have manifest files for.
- Do not proceed further until there are no `Certificate` resources left. You should wait a few minutes and check again to make sure that new `Certificate` resources are not re-created automatically by cert-manager
- Once you are sure that no more resources are returned by `kubectl -n project get certificate`, it is time to update your manifest files and add annotations and labels for the new version of cert-manager (with a `cert-manager.io` prefix)
  - For `Ingress` resources, add the new `cert-manager.io` annotations and labels
  - For `Certificate` resources that are part of your deployments (e.g. to create a certificate that is mounted by an nginx sidecar for your main service), amend the `Certificate`'s annotations and labels
- Deploy the new changes. You should now have a new set of certificate resources. You can verify this with `kubectl -n project get certificate.cert-manager.io`. Note that will list the new `Certificate` resources that you created as well as the ones automatically created by cert-manager on your behalf to manage ingress certificates.
- Identify all the secrets associated with the `Certificate` resources listed in the previous step (secrets have the same name as their associated `Certificate` resources)
  - Back them up
  - Delete them with `kubectl -n project delete secret xxx`. This is required because the current secrets still have annotations related to the old version of cert-manager
  - Watch as the secrets get re-created by the new version of cert-manager

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

### External Ingress changes

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
    secretName: {{ .DEPLOYMENT_NAME }}-external-tls
```

### Internal Ingress changes

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
