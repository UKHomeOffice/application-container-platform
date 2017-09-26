#### Using Ingress Controller
----

An [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) is a type of Kubernetes resource that allows you to expose your services outside the cluster. It gets deployed and managed exactly like other Kube resources.

Our ingress setup offers two different ingresses based on how restrictively you want to expose your services:
- internal - only people within the VPN can access services
- external - anyone with internet access can access services

The annotation ```kubernetes.io/ingress.class: "nginx-internal"``` is used to specify whether the ingress is internal. (```kubernetes.io/ingress.class: "nginx-external"``` is used for an external ingress.)

In the following example the terms "myapp" and "myproject" have been used, these will need to be changed to the relevant names for your project. Where internal is used, this can be changed for an external ingress - everything else stays the same.

```shell
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

#### **Using LetsEncrypt with Ingress**

Assuming you are not bringing your own certificates, LetsEncrypt can be used to acquire certificates for both internal *(behind vpn NOT cluster TLS certs)* and external certificates. Simply place the annotation ```stable.k8s.psg.io/kcm.class: default``` into the ingress resource; A full list of the supported features can be found [here](https://github.com/PalmStoneGames/kube-cert-manager/blob/master/docs/ingress.md). Note at present we ONLY allow you to request certificates via the ingress resource, not by the third party resource.
