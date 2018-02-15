**Kubernetes Pod Autoscaling**

For full documentation on kubernetes autoscaling feature please go [here](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). As of writing the ACP cluster supports standard autoscaling based on a CPU metric, there are however plans to support custom-metrics in the near future.

Assuming you have a deployment 'web' and you wish to autoscale the deployment when it hit's a 40% CPU usage with min/max of 5/10 pods.

```YAML
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: web
spec:
  maxReplicas: 10
  minReplicas: 5
  scaleTargetRef:
    apiVersion: extensions/v1beta1
    kind: Deployment
    name: web
  targetCPUUtilizationPercentage: 40
```
