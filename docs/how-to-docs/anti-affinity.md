## Affinity/Anti-affinity

###  Overview
In Kubernetes you specify an affinity (or anti-affinity) of a pod relative to a group of pods it can be placed with. The node does not have control over the placement. The affinity feature consists of two types, "affinity" and "anti-affinity". 

Pod affinity can tell the scheduler to locate a new pod on the same node as other pods if the label selector on the new pod matches the label on the current pod.

Pod anti-affinity can prevent the scheduler from locating a new pod on the same node as pods with the same labels if the label selector on the new pod matches the label on the current pod.

There are two types of pod affinity rules: required and preferred. Required rules must be met before a pod can be scheduled on a node. You can think of them as "hard" and "soft" respectively, in the sense that the former specifies rules that must be met for a pod to be scheduled onto a node, while the latter specifies preferences that the scheduler will try to enforce but will not guarantee. Anti-affinity is specified as field nodeAffinity of field affinity in the PodSpec.

| Required | Preferred
| ----------- | ----------- |
| `requiredDuringSchedulingIgnoredDuringExecution` | `preferredDuringSchedulingIgnoredDuringExecution` | 
| Specifies rules that must be met for a pod to be scheduled onto a node | Specifies preferences that the scheduler will try to enforce | 
| Example: "co-locate the pods of service A and service B in the same zone, since they communicate a lot with each other" | Example: "spread the pods from this service across zones" (a hard requirement wouldn't make sense, since you probably have more pods than zones). | 

###  Configuring an Anti-affinity Rule

The following example demonstrates how to configure an anti-affinity rule, Based on the [kube-example-app](https://github.com/UKHomeOffice/kube-example-app), the example requires that a pod is not scheduled on the same node as pods which share the same availability zone.

**Example Spec:**
```yml
podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
          labelSelector:
            matchExpressions:
            - key: name
              operator: In
              values:
              - {{ .DEPLOYMENT_NAME }}
           topologyKey: failure-domain.beta.kubernetes.io/zone
...
```
The `Labelselector`, specifies key and value which must be met, based on the pods. To ensure that the conditions are met we specify the topology key `failure-domain.beta.kubernetes.io/zone`, which is based on the [kubernetes label system](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#interlude-built-in-node-labels).










