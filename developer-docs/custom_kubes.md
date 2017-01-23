# Customise your deployment kubes

Sometimes you may need to run a different kube config in development from what you run in production. This is particularly useful when you wish to run an ecrypted connection between pods in production, but not locally or in your ephemeral deployments.

> ** Please note** that you should strive to keep your enviroments production like. You should keep differences between environments to a minimum.

- kd
- separate files
- ConfigMaps

## ConfigMaps

Kubernetes ConfigMaps are resources that holds key-value pairs of configuration data. You can think of ConfigMaps like Kubernetes Secrets wihtout being secret. If you want two different urls in your app depending on the environment, you could have two ConfigMaps as follow:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: <project>
  namespace: <namespace>
data:
  caseworker.rest.url: https://dev-caseworker
```

and

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: <project>
  namespace: <namespace>
data:
  caseworker.rest.url: https://prod-caseworker
```

You can deploy the first ConfigMap with:

```bash
$ kubectl create -f config-dev.yaml
```

And the latter with:

```bash
$ kubectl create -f config-prod.yaml
```

You can use the value from a ConfigMap in the same way you use secrets:

```yaml
env:
  - name: MYVALUE
    valueFrom:
      configMapKeyRef:
          name: <what you have named your config map>
          key: caseworker.rest.url
```

## kd

You already leanrt how to template kube files in one of our [previous episode](#link). You can leverage `kd` templates and introduce `if` statements in your kube files.

```yaml
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: dsp-hello-world
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: dsp-hello-world
    spec:
      containers:
      - name: hello-world-nodejs
        image: dsp-hello-world:v1
        imagePullPolicy: {{if .LOCAL}}ifNotPresent{{else}}AlwaysPull{{end}}
        ports:
          - containerPort: 4000
```

`kd` uses Go as its templating engine. You can find the full list of commands [here](https://golang.org/pkg/text/template/).

## Separate files

Using `kd` is convenient when your kube files differ only for few lines. If the changes are more substantial, you can decide to conditionally load another kube file based on the environment. The following script launches `kd` and is enviroment aware:

```bash
#!/bin/bash

export ENVIRONMENT=${ENVIRONMENT:-"dev"}

cd kube
kd --insecure-skip-tls-verify \
   --file ${ENVIRONMENT}/deployment.yaml
```

You could have a folder for each environment with a set of deployment, service and ingress for each of them.

