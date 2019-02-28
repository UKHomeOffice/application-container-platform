# Kubernetes Pod Autoscaling

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
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 50
```

**Sysdig Metrics - Experimental**

The autoscaler can also consume and make scaling decisions from [sysdig](https://sysdig.digital.homeoffice.gov.uk) metrics. Note, this feature is currently experimental but tested as working.

An example of sysdig would be scaling on http_request

```YAML
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: autoscaler
spec:
  scaleTargetRef:
    apiVersion: extensions/v1beta1
    kind: Deployment
    name: myapplication
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Object
    object:
      target:
        kind: Service
        name: myservice
      metricName: net.http.request.count
      targetValue: 100
```
