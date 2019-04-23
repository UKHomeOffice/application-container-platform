## Downscaling Services Out Of Hours

In an effort to reduce costs on running the platform, we've enabled to capability to scale down specific resources Out Of Hours (OOH) for Non-Production and Production environments.

#### AWS RDS (Relational Database Service)

RDS resources can be transitioned to a stopped state OOH to save on resource utilisation costs. This is currently managed with the use of tags on the RDS instance defining a cronjob schedule to stop and start the instance.

To set a schedule for your RDS instances, please use the related [Support Portal support request template](https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/95).

> **Note:** Shutting down an RDS instance will have cost savings based on the instance size, however you will still be charged for the allocated storage.

#### Kubernetes Pods

Automatically scale down Kubernetes Deployments & Statefulsets to 0 replicas during non-working hours for Non-Production or Production Environments.

Downscaling for Deployments & Statefulsets are managed by an annotation set within the manifest, and are processed every 30 seconds for changes, by a service running within the Kubernetes Clusters.

##### Usage

Set **ONE** of the following annotations on your Deployment / Statefulset:
- `downscaler/uptime`: A time schedule in which the Deployment should be scaled up
- `downscaler/downtime`: A time schedule in which the Deployment should be scaled down to 0 replicas

The annotation values for the timeframe must have the following format to be processed correctly: `<WEEKDAY-FROM>-<WEEKDAY-TO-INCLUSIVE> <HH>:<MM>-<HH>:<MM> <TIMEZONE>`

For example, to schedule a Deployment to only run on weekdays during working hours, the following annotation would be set: `downscaler/uptime: Mon-Fri 09:00-17:30 Europe/London`

> **Note:** When the deployment is downscaled, an additional annotation `downscaler/original-replicas` is automatically set to retain a history of the desired replicas prior to the downscale action. If this annotation has been deleted before the service is automatically scaled back up, the downscaler service will not know what to set the replicas back to, and so it won't attempt to scale up the resource.

**Example Spec:**

```yml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    downscaler/uptime: Mon-Fri 09:00-17:30 Europe/London
  labels:
    name: example-app
  name: example-app
  namespace: acp-example
spec:
  replicas: 2
  template:
    spec:
      containers:
        image: docker.digital.homeoffice.gov.uk/acp-example-app:v0.0.1@sha256:07397c41ac25c4b19e0485006849201f04168703f0016fad75b8ba5d9885d6d4
...
```
