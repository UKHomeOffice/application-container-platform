## Pod Security Policies

By default all user deployments will inherit a default PodSecurityPolicy applied in the Kubernetes Clusters, which define a set of conditions that a pod must be configured with in order to run successfully.

The specification for the default policy is as follows:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: default
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
spec:
  privileged: false
  fsGroup:
    rule: RunAsAny
  hostPID: false
  hostIPC: false
  hostNetwork: false
  runAsUser:
    rule: MustRunAsNonRoot
  requiredDropCapabilities:
    - SETUID
    - SETGID
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - gitRepo
  - persistentVolumeClaim
  - projected
  - secret
```

#### `runAsUser`

This condition requires that the pod specification deploys an image with a non-root user. The user defined in the specification (image spec OR pod spec) must be numeric, so that Kubernetes will be able to verify that it is a non-root user. If this is not done, you may receive any of the following errors in your event log and your pod will be prevented from starting up successfully:
- `container's runAsUser breaks non-root policy`
- `container has runAsNonRoot and image will run as root`
- `container has runAsNonRoot and image has non-numeric user <username>, cannot verify user is non-root`

> **Note:** You can view all recent events in your namespace by running the following command: `kubectl -n my-namespace get events --sort-by=.metadata.creationTimestamp`.


To update your deployment accordingly for the above condition, there are multiple ways to achieve this:

#### Dockerfile

Within the `Dockerfile` for the image you are attempting to run, ensure the `USER` specified references the User ID rather than the username itself. For example:

```
FROM quay.io/gambol99/keycloak-proxy:v2.1.1
LABEL maintainer="rohith.jayawardene@digital.homeoffice.gov.uk"

RUN adduser -D -u 1000 keycloak

USER 1000
```

> **Note:** The following common images have been updated to reference the UID within their respective Dockerfiles. If you use any of these images, updating your deployments to use these versions (or any newer versions) will meet the `MustRunAsNonRoot` requirement for this particular container:
```
quay.io/ukhomeofficedigital/cfssl-sidekick:v0.0.6
quay.io/ukhomeofficedigital/elasticsearch:v1.5.3
quay.io/ukhomeofficedigital/jira:v7.9.1
quay.io/ukhomeofficedigital/keycloak:v3.4.3-2
quay.io/ukhomeofficedigital/kibana:v0.4.4
quay.io/ukhomeofficedigital/go-keycloak-proxy:v2.1.1
quay.io/ukhomeofficedigital/nginx-proxy:v3.2.9
quay.io/ukhomeofficedigital/nginx-proxy-govuk:v3.2.9.0
quay.io/ukhomeofficedigital/redis:v0.1.2
quay.io/ukhomeofficedigital/squidproxy:v0.0.5
```

#### Deployment Spec

In the `securityContext` section of your deployment spec, the `runAsUser` field can be used to set a UID that the image should be run as.

An example spec would include:
```YAML
    spec:
      securityContext:
        fsGroup: 1000
        runAsNonRoot: true
        runAsUser: 1000
      containers:
      - name: "{{ .IMAGE_NAME }}"
        image: "{{ .IMAGE }}:{{ .VERSION }}"
        ...
```
