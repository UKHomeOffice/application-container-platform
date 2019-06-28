# Ingress

#### 0.24.1

- Update to Ingress-nginx 0.24.1: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0241

##### Breaking Changes:
Changes are required to your ingress spec if you are making use of the annotation `ingress.kubernetes.io/rewrite-target`.

Your spec may initially look as follows:
```yml
kind: Ingress
metadata:
  name: web
  annotations:
    ingress.kubernetes.io/rewrite-target: /new
...
```

For a seamless migration without downtime, this annotation must first be replaced similar to below (prior to the upgrade!):
```yml
kind: Ingress
metadata:
  name: web
  annotations:
    ingress.kubernetes.io/configuration-snippet: |
      rewrite "(?i)/old/(.*)" /new/$1 break;
      rewrite "(?i)/old$" /new/ break;
```

Once the upgrade has completed successfully, you can then switch to the following:
```yml
kind: Ingress
metadata:
  name: web
  annotations:
    ingress.kubernetes.io/rewrite-target: /new/$1
```

Please review the official docs for more info: https://kubernetes.github.io/ingress-nginx/examples/rewrite/#rewrite-target

#### 0.21.0

- Update to Ingress-nginx 0.21.0: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0210
- **This includes a breaking change to the `ingress.kubernetes.io/secure-backends: "true"` annotation, it has been deprecated and `ingress.kubernetes.io/backend-protocol: "HTTPS"` introduced. Whilst we upgrade, we recommend having both in place.**

#### 0.15.0

- Update to Ingress-nginx 0.15.0: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0150

#### 0.13.0

- Update to Ingress-nginx 0.13.0: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0130
- Add kube namespace to log messages

#### 0.11.0

- Update to Ingress-nginx 0.11.0: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0110


#### 0.9-beta-2

- Update to Ingress-nginx 0.9-beta-2: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#09-beta2
