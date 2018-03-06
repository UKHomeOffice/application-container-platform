#### **Kubectl Command**

Below is a sample kubeconfig file with two contexts for dev and prod clusters, the file is placed / located at ~/.kube/config by default. You can find a cheat-sheet for the kubectl command [here](https://kubernetes.io/docs/reference/kubectl/cheatsheet)

```YAML
---
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://<KUBE_API_URL>
  name: dev-dsp
- cluster:
    insecure-skip-tls-verify: true
    server: https://<KUBE_API_URL>
  name: prod-dsp
contexts:
- context:
    cluster: dev-dsp
    user: dev-dsp
  name: dev-dsp
- context:
    cluster: prod-dsp
    user: prod-dsp
  name: prod-dsp
current-context: dev-dsp
kind: Config
preferences: {}
users:
- name: dev-dsp
  user:
    token: <TOKEN>
- name: prod-dsp
  user:
    token: <TOKEN>
```
