# Migration from Jetstack cert-manager v0.8 resources to v0.13.1

**In version v0.11, cert-manager has introduced some backwards incompatible changes that were announced in v0.8.**

**Because there are currently 2 instances of cert-manager running on the ACP platform, it is important that your cert-manager related resources are only managed by one of those instances. Otherwise, you run the risk of hitting letsencrypt rate limits as the 2 instances of cert-manager both attempt to manage the same resources.**

**In order to do that, you must de-register your resources with the current version of cert-manager (v0.8) before registering them with the new version of cert-manager (v0.13.1).**

The following official cert-manager documentation provides good background information as to what has changed.

- [v0.8 Release Notes](https://cert-manager.io/docs/release-notes/release-notes-0.8/)
- [v0.11 Release Notes](https://cert-manager.io/docs/release-notes/release-notes-0.11/)
- [Upgrading from v0.7 to v0.8](https://cert-manager.io/docs/installation/upgrading/upgrading-0.7-0.8/)
- [Upgrading from v0.10 to v0.11](https://cert-manager.io/docs/installation/upgrading/upgrading-0.10-0.11/)

Essentially, the cert-manager API version has been changed from `certmanager.k8s.io/v1alpha1` to `cert-manager.io/v1alpha2`. This means that both `Ingress` and `Certificate` resources have to be changed: there are annotations and labels changes for both resource types, as well as structural changes for `Certificate`s.

Please note that when update annotations and labels, you should only do that on resources you have created yourselves.

For example, if you your manifest file contains a `Certificate` resource definition to terminate TLS on a sidecar, you should update annotations and labels as described below.

However, please be aware that when annotating an `Ingress` resource with cert-manager annotations, cert-manager will automatically create a `Certificate` resource to handle certificate resources to LetsEncrypt. Those `Certificate` resources internally managed by cert-manager should not be modified.

**IMPORTANT NOTE:**

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

## Step 1 - Unregistering resources from v0.8

### Ingresses

- Update all your ingress resources and remove ***all*** `certmanager.k8s.io` annotations (make sure that it is back up or can be re-created from git)
- Deploy your ingress changes
- Wait a minute or so and verify that the certificate resource with the same name as the secret name specified in the ingress (or is it the ingress name?) is no longer present with `kubectl get certificates -n my-namespace`. If a certificate is re-created, double-check your ingress annotations.

### Certificates

The instructions in this section only apply to certificate resources that have been created from a manifest file: the certificate resources automatically managed by cert-manager because of ingress resources are expected to have been deleted automatically by cert-manager if the previous section on ingresses has been carried out successfully.

For certificate resources manually created:

- Delete the `Certificate` resource (make sure that it is back up or can be re-created from git)

## Step 2 - Updating the resources for v0.11+

Note that:

1) All `Certificate` resources should be deleted: the ones managed by the ingress shim controller and the ones for which you have `Certificate` manifests.
2) Although the certificate resources have been deleted, this will not affect the secrets containing the TLS private key and signed certificate. That's because, by default, cert-manager does not delete the secrets specified in a certificate object when that certificate object is deleted. This means that your service will continue having a valid certificate until it expires, so you have some time (usually at least 4 weeks) to complete the migration.

An example of removing the annotations can be found in [kube-example-app](https://github.com/UKHomeOffice/kube-example-app/commit/a161ea22563e45fcd87141933118d2102caa4dc1).

The following examples are based on the [kube-example](https://github.com/ukhomeoffice/kube-example-app) project.

An example of updating annotations and labels can be found in [kube-example-app](https://github.com/UKHomeOffice/kube-example-app/commit/379a6da037a91089726bd0b335db87a3e723208e) but they are also explained below.

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

### Deployment verification

Once you have applied the changes above, you should no longer have `Certificate` resources managed by v0.8.

To verify that's the case, run `kubectl get certificate -n my-namespace`. The resource list returned should be empty.

To verify that the new version of cert-manager is managing the certificates, run `kubectl get certificate.cert-manager.io -n my-namespace`. An non-empty list of resources should be returned, including any certificate resources you have created yourselves as well as ones created by cert-manager on behalf of an ingress.

Once the development teams have migrated all their resources to the new version of cert-manager, the old instance will be decommissioned. When that's done it will no longer be needed to append `.cert-manager.io` to the resource kinds when using `kubectl`.

### Final step

In order to be 100% sure that there won't be an issue renewing certificates, you can verify that the new version of cert-manager is able to generate new secrets:

- Back up the secret resources that are specified as `secretName` in the `Ingress` and `Certificate` resources
- Delete those secrets
- Observe the secrets being re-created over a few tens of seconds
