# Using Ingress Controller

An [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) is a type of Kubernetes resource that allows you to expose your services outside the cluster. It gets deployed and managed exactly like other Kube resources.

Our ingress setup offers two different ingresses based on how restrictively you want to expose your services:
- internal - only people within the VPN can access services
- external - anyone with internet access can access services

The annotation ```kubernetes.io/ingress.class: "nginx-internal"``` is used to specify whether the ingress is internal. (```kubernetes.io/ingress.class: "nginx-external"``` is used for an external ingress.)

In the following example the terms "myapp" and "myproject" have been used, these will need to be changed to the relevant names for your project. Where internal is used, this can be changed for an external ingress - everything else stays the same.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    # used to select which ingress this resource should be configured on
    kubernetes.io/ingress.class: "nginx-internal"
    # indicate the ingress SHOULD speak TLS between itself and pods
    ingress.kubernetes.io/secure-backends: "true"
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

> Always ensure you are using TLS between the ingress controller and your pods by placing the annotation: "ingress.kubernetes.io/secure-backends": "true". At the moment; this is not enforced though there are plans to enforce by policy at a later date.

## **Using LetsEncrypt with Ingress**

Assuming you are not bringing your own certificates, LetsEncrypt can be used to acquire certificates for both internal *(behind vpn NOT cluster TLS certs)* and external certificates. Simply place the annotation ```stable.k8s.psg.io/kcm.class: default``` into the ingress resource; A full list of the supported features can be found [here](https://github.com/PalmStoneGames/kube-cert-manager/blob/master/docs/ingress.md). Note at present we ONLY allow you to request certificates via the ingress resource, not by the third party resource.

### External Ingress

Below is an example of an ingress resource for a HTTPS host reachable over the internet.

**Pre-Reqs:**
- The host `my-app.my-project.homeoffice.gov.uk` has a CNAME record to `ingress-external.prod.acp.homeoffice.gov.uk` (or relevant `ingress-external` address for the cluster you are using)

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/secure-backends: "true"
    kubernetes.io/ingress.class: nginx-external
    stable.k8s.psg.io/kcm.provider: http
  labels:
    stable.k8s.psg.io/kcm.class: default
  name: my-app
  namespace: my-namespace
spec:
  rules:
  - host: my-app.my-project.homeoffice.gov.uk
    http:
      paths:
      - backend:
          serviceName: my-app
          servicePort: 443
        path: /
  tls:
  - hosts:
    - my-app.my-project.homeoffice.gov.uk
    secretName: my-app-external-tls
```

### Internal Ingress

Below is an example of an ingress resource for a HTTPS host reachable via VPN or services on the private network.

**Pre-Reqs:**
- The host `my-app.my-project.homeoffice.gov.uk` has a CNAME record to `ingress-internal.prod.acp.homeoffice.gov.uk` (or relevant `ingress-internal` address for the cluster you are using)
- The host `my-app.my-project.homeoffice.gov.uk` is managed via Route53 within the same account that the cluster is running within (done by ACP team)
- The host `my-app.my-project.homeoffice.gov.uk` (or TLD) is listed as a [Hosted Domain](https://github.com/UKHomeOffice/policy-admission/blob/master/pkg/authorize/kubecertmanager/doc.go#L33) within the custom policy admission controller (done by ACP team)

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/secure-backends: "true"
    kubernetes.io/ingress.class: nginx-internal
  labels:
    stable.k8s.psg.io/kcm.class: default
  name: my-app
  namespace: my-namespace
spec:
  rules:
  - host: my-app.my-project.homeoffice.gov.uk
    http:
      paths:
      - backend:
          serviceName: my-app
          servicePort: 443
        path: /
  tls:
  - hosts:
    - my-app.my-project.homeoffice.gov.uk
    secretName: my-app-internal-tls
```
