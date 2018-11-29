# Ingress Release Notes

## 0.21.0

- Update to Ingress-nginx 0.21.0: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0210
- **This includes a breaking change to the `ingress.kubernetes.io/secure-backends: "true"` annotation, it has been deprecated and `ingress.kubernetes.io/backend-protocol: "HTTPS"` introduced. Whilst we upgrade, we recommend having both in place.**

## 0.15.0

- Update to Ingress-nginx 0.15.0: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0150

## 0.13.0

- Update to Ingress-nginx 0.13.0: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0130
- Add kube namespace to log messages

## 0.11.0

- Update to Ingress-nginx 0.11.0: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0110


## 0.9-beta-2

- Update to Ingress-nginx 0.9-beta-2: https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#09-beta2
