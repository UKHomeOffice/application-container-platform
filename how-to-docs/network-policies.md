# Network Policies

By default a deny-all policy is applied to every namespace in each cluster.

You can however add network policies to your own projects to allow for certain connections and these will be applied on top of the default deny-all policy.

Here is an example network policy for allowing a connection from the ingress-internal namespace:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-network-policy
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

For more information, see the [Kubernetes documentation on network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
