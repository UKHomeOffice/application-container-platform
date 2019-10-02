## Using Ingress

An [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) is a type of Kubernetes resource that allows you to expose your services outside the cluster. It gets deployed and managed exactly like other Kube resources.

Our ingress setup offers two different ingresses based on how restrictively you want to expose your services:
- internal - only people within the VPN can access services
- external - anyone with internet access can access services

The annotation `kubernetes.io/ingress.class: "nginx-internal"` is used to specify whether the ingress is internal. (`kubernetes.io/ingress.class: "nginx-external"` is used for an external ingress.)

In the following example the terms "myapp" and "myproject" have been used, these will need to be changed to the relevant names for your project. Where internal is used, this can be changed for an external ingress - everything else stays the same.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    # used to select which ingress this resource should be configured on
    kubernetes.io/ingress.class: "nginx-internal"
    # Indicate the ingress SHOULD speak TLS between itself and pods (best-practice)
    ingress.kubernetes.io/backend-protocol: "HTTPS"
  name: myapp-server-internal
spec:
  rules:
  - host: "myapp.myproject.homeoffice.gov.uk"
    http:
      paths:
      - backend:
          serviceName: myapp
          servicePort: 8000
        path: /
  tls:
  - hosts:
    - "myapp.myproject.homeoffice.gov.uk"
    # the name of the kubernetes secret in your namespace with tls.crt and tls.key
    secretName: myapp-github-internal-tls
```

Please view the official documentation for a full list of available [ingress-nginx annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/).

> **Note:** Where the prefix for the annotation in the docs references `nginx.ingress.kubernetes.io/`, this should be changed to `ingress.kubernetes.io/` when running within ACP (as per the above example).
