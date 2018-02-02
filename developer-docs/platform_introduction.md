# Developer Introduction to the Platform

## Introduction

This guide is aimed at developers that have already completed the [initial setup](./dev_setup.md).
It covers how to manually deploy an application to the platform, and some advice for debugging applications on the platform.

1. [Deploying an application locally](#deploying-an-application-locally)
2. [Deploying an application to the platform](#deploying-an-application-to-the-platform)
3. [Deploying secrets](#deploying-secrets)
4. [Debugging issues with your application](#debugging-issues-with-your-deployments-to-the-platform)

**You have to be on the VPN to follow this tutorial.**

## Deploying an application locally

### Starting minikube

Start your Kubernetes cluster locally with minikube:

```bash
$ minikube start
```

Minikube runs a virtual machine with docker and kubernetes (among other things). We must tell our local docker client
to talk to the docker daemon running in the minikube VM, rather than our local docker daemon. The following command will set
your docker host and related variables to make this possible:

```bash
$ eval $(minikube docker-env)
```

If the command was successful, you should be able to see few kubernetes containers running inside the virtual machine from your host:

```bash
$ docker ps --format "{{.ID}}: {{.Image}}"
a6d25657a6e1: gcr.io/google_containers/kube-dnsmasq-amd64:1.4
994ef2f40aaa: gcr.io/google_containers/kubedns-amd64:1.8
be2ce6e2422b: gcr.io/google_containers/exechealthz-amd64:1.2
1716372d439e: gcr.io/google_containers/kubernetes-dashboard-amd64:v1.5.0
4818ea28904a: gcr.io/google_containers/pause-amd64:3.0
ee56c7a18942: gcr.io/google_containers/pause-amd64:3.0
c412afff3115: gcr.io/google-containers/kube-addon-manager:v5.1
0f0f5cbaa917: gcr.io/google_containers/pause-amd64:3.0
```

### Dockerise "Hello World"

For this demo we will use a simple nodejs application:  [UKHomeOffice/acp-hello-world](https://github.com/UKHomeOffice/acp-hello-world)

You can clone the repository on your machine with:

```bash
$ git clone https://github.com/UKHomeOffice/acp-hello-world
```

> **Please note** that this application is already dockerised. If you are dockerising a different application please follow the Home Office guidance [here](./writing_dockerfiles.md).

You can build the application with:

```bash
$ docker build -t acp-hello-world:v1 .
Successfully built 985301b648c5
```

Since the docker daemon is running in the virtual machine, no image is created on your host. You can verify the image was created successfully with:

```bash
$ docker images | grep acp-hello-world
acp-hello-world                                       v1                  53bfe98bf88f
```

### Deploy to Kubernetes

A deployment defines what application you want to run (which can consist of multiple containers) and how many replicas you want.

In this particular case we want to run our Node.js container as a single container.

```yaml
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: acp-hello-world
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: acp-hello-world
    spec:
      containers:
      - name: hello-world-nodejs
        image: acp-hello-world:v1
        imagePullPolicy: ifNotPresent
        ports:
          - containerPort: 4000
```

This file is already saved as `deployment.yaml` in the `kube` folder.

You can deploy the application to minikube with:

```bash
$ kubectl create -f kube/deployment.yaml
deployment "acp-hello-world" created
```

If the deployment was successful, you should see a running container:

```bash
$ kubectl get pods
NAME                               READY     STATUS    RESTARTS   AGE
acp-hello-world-3757754181-x1kdu   1/1       Running   0          4s
```

If the deployment wasn't successful and the status is `ErrImagePull` you can inspect the deployment logs with:

```bash
$ kubectl describe pod <acp-hello-world-3757754181-x1kdu>
```

### Define a service

The Node.js application is deployed, but it isn't exposed to the outside world. To expose the application you have to deploy a service. A service is similar to a load balancer, requests to the containers are routed through services.

The repository already has a service. You can find it in `kube/service.yaml`.

```yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    name: acp-hello-world-service
  name: acp-hello-world-service
spec:
  ports:
  - name: exposed-port
    port: 80
    targetPort: 4000
  selector:
    name: acp-hello-world
```

You can deploy the service with:

```bash
$ kubectl create -f kube/service.yaml
service "acp-hello-world-service" created
```

You can list the services in kubernetes with:

```bash
$ kubectl get services
NAME                      CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
acp-hello-world-service   10.0.0.213   <none>        80/TCP    27s
kubernetes                10.0.0.1     <none>        443/TCP   5h
```

If the deployment was successful, you can login into the cluster and issue an http request:

```bash
$ minikube ssh
Boot2Docker version 1.11.1, build master : 901340f - Fri Jul  1 22:52:19 UTC 2016
Docker version 1.11.1, build 5604cbe
```

You can verify the application is running with

```bash
$ curl <10.0.0.213>
Hello World
```

If you can read _"Hello World"_ the deployment was successful.

### Define an ingress

Your application is only available within your cluster, but there isn't an easy way to visit the application from the host. You can expose your application to be consumed by any body using an ingress.

The repository already contains a simple ingress manifest in `kube/ingress.yaml`:

```yaml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: acp-hello-world-ingress
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: acp-hello-world-service
          servicePort: 80
        path: /
```

You can create an ingress with:

```bash
$ kubectl create -f kube/ingress.yaml
ingress "acp-hello-world-ingress" created
```

If the installation was successful, you should be able to visit the virtual machine ip on port 80 and be greeted by _"Hello World no secret set"_.

You can find the ip address of your cluster with:

```bash
$ minikube ip
192.168.64.3
```

Visit http://<192.168.64.3>

### Re-deploy with kd

Deploying with `kubectl` has some limitations - in particular that it isn't possible to template out variables, making similar deployments to different environments very cumbersome. You can use a tool called `kd` to overcome this constraint.

[You can download kd here](https://github.com/UKHomeOffice/kd/releases). Please download the latest release for your computer.
You will then need to make it executable and ideally move it to somewhere on your PATH and rename it to kd.

```bash
$ chmod +x kd_linux_amd64
$ sudo mv kd_linux_amd64 /usr/local/bin/kd
```

You can then re-deploy to minikube with a single command:

```bash
$ kd --file kube/deployment.yaml \
     --file kube/service.yaml \
     --file kube/ingress.yaml
```

## Deploying an application to the platform

The same configuration you just created can be used to deploy the application to any of the clusters such as CI, Dev and Prod.

In this particular scenario you can deploy your service to the **dev-induction** namespace. Typically you would be using one of your project namespace.

You will need to update your kubernetes context - this determines which cluster you are talking to, which token to use, and which namespace you are using. You can view your current contexts with:

```bash
$ kubectl config view
```

If you have a context set with the dev cluster (https://kube-dev.dsp.notprod.homeoffice.gov.uk) and the _dev-induction_ namespace change to that context with:

```bash
$ kubectl config use-context <context-name>
```

If you don't have this context you can set it with:

```bash
$ kubectl config set-context dev-induction \
          --cluster=dsp-dev \
          --user=dsp-dev \
          --namespace=dev-induction
```

To ensure people on the induction don't have name clashes with their deployed applications we are going to use a version of our deployment files where the application name has been templated out. [kd](https://github.com/UKHomeOffice/kd) is a tool that wraps kubectl and enables us to do this templating.

Please specify a unique `APP_NAME` with your initials and some random characters when you deploy. You will also noted the image version is templated out - a very common pattern. Please use _v1_ for the version.

```bash
$ APP_NAME=tgxu172 \
  APP_VERSION=v1 \
  MY_SECRET=$(echo 'whysoserious' | base64) \
  kd --file kube-templated/secret.yaml \
     --file kube-templated/deployment.yaml \
     --file kube-templated/service.yaml \
     --file kube-templated/ingress.yaml
```

Also note this deployments has some improvements over the last one:

- The deployment now contains an nginx instance which terminates TLS, increasing the security of our traffic
- The service directs to the nginx port instead of the app port
- The ingress specifies TLS certificates to use (these are already in the _dev-induction_ namespace)
- The ingress specifies a host which determines which requests should be routed to our application

The application is now available at http://<tgxu172>.notprod.homeoffice.gov.uk (replacing _<tgxu172>_ with your `APP_NAME` variable).

## Deploying secrets

Your application is likely to have some parameters that are essential to the security of the application - for example API tokens and DB passwords. These should be stored as Kubernetes secrets to enable your application to read them. This process is described in the following guide.

See [official docs](http://kubernetes.io/docs/user-guide/secrets/#creating-a-secret-using-kubectl-create-secret) for more complete documentation; what follows is a very abridged version.

### Generate a strong secret

When generating passwords you should use the following code to ensure you are generating strong passwords.

```bash
$ LC_CTYPE=C tr -dc "[:print:]" < /dev/urandom | head -c 32
```

### Create a kubernetes secret

Create a file called **example-secret.yaml** with the following content below.
In this example, when deployed it will create a kubernetes secret called `my-secret`. Feel free to replace the name `my-secret` with something else, especially if you are working in a group and going through this exercise for the Developer Induction. If you don't you will most likely overwrite each others secret when deploying to Kubernetes:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  supersecret: {{.MY_SECRET}}
```

> *Please note* that you shouldn't commit passwords or sensitive information in your
> repository. We suggest you use environment variables to load secrets into the
> yaml file.

Secrets are passed to kubernetes as base64 encoded strings. To encode or decode a base64 string use the following commands:

```bash
$ echo -n "yay it is a secret" | base64
$ echo eWF5IGl0IGlzIGEgc2VjcmV0 | base64 -D
```

Now let's deploy our secret to Kubernetes:

```bash
$ export MY_SECRET=$(echo -n "replace this secret with something more exciting please!" | base64)
$ kd --file example-secret.yaml
```

### See and edit the stored secrets

You can retrieve the secret with:

```bash
$ kubectl get secrets
$ kubectl describe secret <my-secret>
```

If you wish to edit secrets already loaded in to Kubernetes you can do so by downloading and reapplying the manifest. You can download the secrets as a Yaml file with:

```bash
$ kubectl get secret <my-secret> -o yaml > example-secrets.yaml
```

You can edit the content of  `example-secrets.yaml`, but remember: values are base64 encoded. If you wish to inspect or add a new entry, you need to decode or encode that value.

Once you're done with the changes, you can reapply all the secrets with:

```bash
$ kubectl apply -f example-secrets.yaml
```

> Please note that it's possible to append a key value pair to an existing secret. You can however download the secret's manifest and reapply the changes as explained above.

### Use the secrets

You can mount secrets into your application using either mounted volumes or by using them as environment variables.

The below example shows a deployment that does both. However for this challenge please update your deployment in acp-hello-world to use your secret as an environment variable called MYSUPERSECRET.

<details>
<summary>**This yaml is an example! Please do not copy and paste, just use it as a guide to modify your own deployment.yaml!**</summary>

```yaml
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: induction-hello-world
spec:
  volumes:
    - name: "secretstest"
      secret:
        secretName: mysecret
  containers:
    - image: nginx:1.9.6
      name: awebserver
      volumeMounts:
        - mountPath: "/tmp/mysec"
          name: "secretstest"
      env:
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
                name: my-secret
                key: dbpass
        - name: USERNAME
          valueFrom:
            secretKeyRef:
                name: my-secret
                key: dbuser
        - name: HOST
          valueFrom:
            secretKeyRef:
                name: my-secret
                key: dbhost
```
</details>

For your own deployment.yaml file you should have an env section in the appropriate place that looks similar to this. The `name` and `key` fields should be the same:

```yaml
env:
  - name: MYSUPERSECRET
    valueFrom:
      secretKeyRef:
          name: <what you have named your secret>
          key: supersecret
```

Once you've updated your deployment file to set the `MYSUPERSECRET` environment variable using the kubernetes secret, you will need to redeploy it:

```bash
$ APP_NAME=tgxu172 \
  APP_VERSION=v1 \
  kd --file kube-templated/deployment.yaml
```

Now when you navigate to https://tgxu172.notprod.homeoffice.gov.uk/ you should see your secret outputted as part of the message.

### Debug with secrets

Sometimes your app doesn't want to talk to an API or a DB and you've stored the credentials or just the details of that in secret.

The following approaches can be used to validate that your secret is set correctly

```bash
$ kubectl exec -ti my-pod -c my-container -- mysql -h\$DBHOST -u\$DBUSER -p\$DBPASS
## or
$ kubectl exec -ti my-pod -c my-container -- openssl verify /secrets/certificate.pem
## or
$ kubectl exec -ti my-pod -c my-container bash
## and you'll naturally have all the environment variables set and volumes mounted.
## however we recommend against outputing them to the console e.g. echo $DBHOST
## instead if you want to assert a variable is set correctly use
$ [[ -z $DBHOST ]]; echo $?
## if it returns 1 then the variable is set.
```

## Debugging issues with your deployments to the platform

If you get to the end of the above guide but can't access your application there are a number of places something could be going wrong.
This section of the guide aims to give you some basic starting points for how to debug your application.

### Debugging deployments

We suggest the following steps:

#### 1. Check your deployment, replicaset and pods created properly

```bash
$ kubectl get deployments
$ kubectl get rs
$ kubectl get pods
```

#### 2. Investigate potential issues with your pods (this is most likely)

If the get pods command shows that your pods aren't all running then this is likely where the issue is. You can then try curling your application to see if it is alive and responding as expected. e.g.

```bash
$ curl localhost:4000
```

You can get further details on why the pods couldn't be deployed by running:

```bash
$ kubectl describe pods *pods_name_here*
```

If your pods are running you can check they are operating as expected by `exec`ing into them (this gets you a shell on one of your containers).

```bash
$ kubectl exec -ti *pods_name_here* -c *container_name_here* /bin/sh
```

> **Please note** that the `-c` argument isn't needed if there is only one container in the pod.*

#### 3. Investigate potential issues with your service

A good way to do this is to run a container in your namespace with a bash terminal:

```bash
$ kubectl run -ti --image quay.io/ukhomeofficedigital/centos-base debugger bash
```

From this container you can then try curling your service. Your service will have a nice DNS name by default, so you can for example run:

```bash
$ curl my-service-name
```

#### 4. Investigate potential issues with ingress

Minikube runs an ingress service using nginx. It's possible to ssh into the nginx container and cat the `nginx.conf` to inspect the configuration for nginx.

In order to attach to the nginx container, you need to know the name of the container:

```shell
$ kubectl get pods
NAME                               READY     STATUS    RESTARTS   AGE
default-http-backend-2kodr         1/1       Running   1          5d
acp-hello-world-3757754181-x1kdu   1/1       Running   2          6d
ingress-3879072234-5f4uq           1/1       Running   2          5d
```

You can attach to the running container with:

```bash
$ kubectl exec -ti <ingress-3879072234-5f4uq> -c <proxy> bash
```

where `<proxy>` is the container name of the nginx proxy inside the pod. You can find the name by describing the pod.

You're inside the container. You can cat the `nginx.conf` with:

```bash
$ cat /etc/nginx/nginx.conf
```

You can also inspect the logs with:

```bash
$ kubectl logs <ingress-3879072234-5f4uq>
```
