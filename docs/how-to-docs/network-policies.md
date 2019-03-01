## Network Policies

By default a deny-all policy is applied to every namespace in each cluster.

You can however add network policies to your own projects to allow for certain connections and these will be applied on top of the default deny-all policy.

Here is an example network policy for allowing a connection from the ingress-internal namespace:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-network-policy
  namespace: <your-namespace-here>
spec:
  podSelector:
    matchLabels:
      role: artifactory
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-internal
      ports:
        - protocol: TCP
          port: 443
```

The port number should be the same as the one that your service is listening on.

#### Controlling Egress Traffic

Kubernetes v1.8 with Calico v2.6 adds support to limit egress traffic via the use of Kubernetes Network Policies.

An example of a policy document blocking ALL egress traffic for a given namespace is below:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-egress
  namespace: <your-namespace-here>
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
  - Egress
```

**NOTE:** The above document will also prevent DNS access for all pods in the namespace. To allow DNS egress traffic via the `kube-system` namespace, you can apply the following Network Policy document within your namespace (which takes precedence over `deny-all-egress`):
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-access
  namespace: <your-namespace-here>
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```



For more information, please see the following:
- [Kubernetes documentation on network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Kubernetes advanced network policy examples](https://docs.projectcalico.org/master/getting-started/kubernetes/tutorials/advanced-policy)
