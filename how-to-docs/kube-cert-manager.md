## **Kube-Cert-Managaer & Cloudflare SSL**
-----
Services:
- [kube-cert-manager](https://github.com/PalmStoneGames/kube-cert-manager) is used to retrieve Letencrypt certificates.
- [cfssl](https://github.com/cloudflare/cfssl) is an internal certificate service used to provide internal tls between pods / services.

#### **Domains and Challenge types**

At present two Let's Encrypt challenge types are supported for certificates which is controlled via the `stable.k8s.psg.io/kcm.provider` annotation on the Ingress resource; note if no annotation is present the default is `stable.k8s.psg.io/kcm.provider: dns`.

- dns: the domain must be hosted within the ACP route53 account, namely to allow kube-cert-manager to add the service record. If you are unsure if this is the case please check with the ACP team. DNS is optional for external sites but a requirement for sites seated behind the VPN.
- http: indicates a callback url for authentication. The domain can either be controlled externally via yourself or via the ACP team. Either way the dns record must be a CNAME to the external ingress hostname _(please check with the ACP team if you dont know)_. Obviously this challenge type can only be used on an external site. Note any IP white-listing on the ingress can still be used.

#### **As a developer I want to grab a certificate from Letsencrypt**

Below is an example of an ingress resource for a HTTPS host reachable over the internet. Note, your ingress resource using IP whitelisting is irrelivant here in regard to Letsencrypt i.e you can still protect the site with and ACL.

- The host `my-app.my-project.homeoffice.gov.uk` has a CNAME record to `ingress-external.prod.acp.homeoffice.gov.uk` (or relevant `ingress-external` address for the cluster you are using)

```YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/secure-backends: "true"
    kubernetes.io/ingress.class: nginx-external
    # ensure kube-cert-manager uses a http01 challenge
    stable.k8s.psg.io/kcm.provider: http
  labels:
    # this is a toggle to indicate kube-cert-manager should handle this resource
    stable.k8s.psg.io/kcm.class: default
  name: my-app
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

#### **As a developer I want a certificate from a site behind the vpn**

Using Letsencrypt

Below is an example of an ingress resource for a HTTPS host reachable via VPN or services on the private network.

- The host `my-app.my-project.homeoffice.gov.uk` has a CNAME record to `ingress-internal.prod.acp.homeoffice.gov.uk` (or relevant `ingress-internal` address for the cluster you are using)
- The host `my-app.my-project.homeoffice.gov.uk` is managed via Route53 within the same account that the cluster is running within (done by ACP team)
- The host `my-app.my-project.homeoffice.gov.uk` (or TLD) is listed as a [Hosted Domain](https://github.com/UKHomeOffice/policy-admission/blob/master/pkg/authorize/kubecertmanager/doc.go#L33) within the custom policy admission controller (done by ACP team)

```YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/secure-backends: "true"
    kubernetes.io/ingress.class: nginx-internal
  labels:
    stable.k8s.psg.io/kcm.class: default
  name: my-app
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

#### **Using LetsEncrypt with Ingress**

Assuming you are not bringing your own certificates, LetsEncrypt can be used to acquire certificates for both internal *(behind vpn NOT cluster TLS certs)* and external certificates. Simply place the annotation ```stable.k8s.psg.io/kcm.class: default``` into the ingress resource; A full list of the supported features can be found [here](https://github.com/PalmStoneGames/kube-cert-manager/blob/master/docs/ingress.md). Note at present we ONLY allow you to request certificates via the ingress resource, not by the third party resource.

#### **As a developer I want a certificate for my pod / service**

##### **The CA bundle**

By default, in all namespaces a CA bundle has been added which can been mounted into the /etc/ssl/certs of the container and which contains the root CA used to verify authenticity of the certificates. An example of using it is given below.

Below is example of how to acquire a certificate from CloudflareSSL.


```YAML
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: example
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        name: example
    spec:
      volumes:
      - name: bundle
        configMap:
          name: bundle
      - name: certs
        emptyDir: {}
      initContainers:
      - name: certs
        # PLEASE do not use latest, but check for the latest tag in the releases page of https://github.com/UKHomeOffice/cfssl-sidekick
        image: quay.io/ukhomeofficedigital/cfssl-sidekick:latest
        securityContext:
          runAsNonRoot: true
        args:
        - --certs=/certs
        - --domain=myservice.${KUBE_NAMESPACE}.svc.cluster.local
        - --domain=another_domain_name
        - --expiry=8760h
        env:
        - name: KUBE_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        # an emptyDir which the sidekicks writes the certificates
        - name: certs
          mountPath: /certs
        # The platform CA Bundle hold the root ca used to verify the certificate chain
        - name: bundle
          mountPath: /etc/ssl/certs
          readOnly: true
      containers:
      - name: your_application
        image: quay.io/ukhomeofficedigital/some_image
        ...
        ports:
        - name: https
          port: 443
          targetPort: 443
        volumeMounts:
        # You can configure your application to pick up the certificates from here (tls.pem and tls-key.pem)
        - name: certs
          mountPath: /certs
          readOnly: true
```

To break down what is happening. Firstly we are adding two volumes `bundle` and `certs`.

- the `bundle` volume is mapped to a configmap which as indicated above is published by us into every namespace and contains the a certificate bundle. This is mounted into the default PKI directory of the container `/etc/ssl/certs` and permits the container to trust the service.
- the `certs` is a emptyDir which is a [tmpfs](https://en.wikipedia.org/wiki/Tmpfs) volume and used to share the cecertificates between the sidekick and your application.

We then inject into the [initContainers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) the sidekick service. The sidekick is responsible for

- locally generating a private key _(the private key itself never crosses the wire)_
- generating a CSR for the certificate and requesting a signing from cloudflare service.
- once the certificate has been signed its placed into `--certs=dir` directory which in this case is the emptyDir shared across the containers.

Note, if you wish to trust certificates generated by this service simply mounted the bundle into the certificates dorectory.

