# Getting A Certificate

When using an Ingress with your application you can get a Certificate automatically generated for you.
You do this by setting the tls-acme flag to true, an example ingress is shown below.
```yaml
apiVersion: extensions/v1beta1  
kind: Ingress
metadata:    
  name: myapp
  annotations:
    kubernetes.io/tls-acme: "true"
spec:
  tls:
  - hosts:      
    - myapp.myproject.homeoffice.gov.uk
    secretName: myapp-tls
    rules:
    - host: myapp.myproject.homeoffice.gov.uk
      http:
        paths:
        - path: /
          backend:
            serviceName: myapp
            servicePort: 443

```
Your host name should follow this general pattern to avoid running out of certs:
```
myapp.dev.myproject.homeoffice.gov.uk
myapp.preprod.myproject.homeoffice.gov.uk
myapp.myproject.homeoffice.gov.uk
```
