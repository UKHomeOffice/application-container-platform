#### **Kubernetes API Security Policy**

With Kubernetes still in it's infancy much of the multi-tenancy has yet to be finished. One such
item left on the agenda is how to enforce a security policy on a service account, group, namespace etc
level. At present, without a security policy the user can perform pretty much what they like, pushing
containers with privileged mode, mapping to the host network or mounting sensitive files from the host
machine. The [kube-cover](https://github.com/UKHomeOffice/kube-cover) project is a temporary hack to permit
us applying policies to users, while we wait the Kubernetes to address the issue in a release.

* **Setup**

You must been to upload a policy file via s3secrets; the expected path is BUCKET/kube-policy/FILE.json

```shell
$ cd kube/dev
$ s3secrets s3 put -p kube-policy/ api-policy.json
```

* **Start Kube Policy**

```shell
$ fleetctl start unit/kubernetes/kube-policy.service
```
