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

Minikube runs a virtual machine with docker and kubernetes (among other things). To access the docker deamon inside the virtual machine you can run:

```
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

For this demo we will use a simple nodejs application:  [UKHomeOffice/dsp-hello-world](https://github.com/UKHomeOffice/dsp-hello-world)

You can clone the repository on your machine with:

```bash
$ git clone https://github.com/UKHomeOffice/dsp-hello-world
```

> **Please note** that this application is already dockerised. If you are dockerising a different application please follow the Home Office guidance [here](./writing_dockerfiles.md).

You can build the application with:

```bash
$ docker build -t dsp-hello-world:v1 .
Successfully built 985301b648c5
```

Since the docker daemon is running in the virtual machine, no image is created on your host. You can verify the image was created successfully with:

```bash
$ docker images | grep dsp-hello-world
dsp-hello-world                                       v1                  53bfe98bf88f
```

### Deploy to Kubernetes

A deployment defines what application you want to run (which can consist of multiple containers) and how many replicas you want.

In this particular case we want to run our Node.js container as a single container.

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
        imagePullPolicy: ifNotPresent
        ports:
          - containerPort: 4000
```

This file is already saved as `deployment.yaml` in the `kube` folder.

You can deploy the application to minikube with:

```bash
$ kubectl create -f kube/deployment.yaml
deployment "dsp-hello-world" created
```

If the deployment was successful, you should see a running container:

```bash
$ kubectl get pods
NAME                               READY     STATUS    RESTARTS   AGE
dsp-hello-world-3757754181-x1kdu   1/1       Running   0          4s
```

If the deployment wasn't successful and the status is `ErrImagePull` you can inspect the deployment logs with:

```bash
$ kubectl describe pod <dsp-hello-world-3757754181-x1kdu>
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
    name: dsp-hello-world-service
  name: dsp-hello-world-service
spec:
  ports:
  - name: exposed-port
    port: 80
    targetPort: 4000
  selector:
    name: dsp-hello-world
```

You can deploy the service with:

```bash
$ kubectl create -f kube/service.yaml
service "dsp-hello-world-service" created
```

You can list the services in kubernetes with:

```
$ kubectl get services
NAME                      CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
dsp-hello-world-service   10.0.0.213   <none>        80/TCP    27s
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
  name: dsp-hello-world-ingress
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: dsp-hello-world-service
          servicePort: 80
        path: /
```

You can create an ingress with:

```bash
$ kubectl create -f ingress.yaml
ingress "dsp-hello-world-ingress" configured
```

If the installation was successful, you should be able to visit the virtual machine ip on port 8081 and be greeted by _"Hello World"_.

You can find the ip address of your cluster with:

```bash
$ minikube ip
192.168.64.3
```

Visit http://<192.168.64.3>:8081

## Deploying an application to the platform

The same configuration you just created  can be used to deploy the application to any of the clusters such as CI, Dev and Prod.

> Before you start deploying to a real cluster make sure you have a valid Kubernetes token to create and destroy a namespace(s) in the CI cluster. If you don't ,please follow [this instructions](#todo) to request a valid token.

You can create a partition of the cluster using Kubernetes namespaces. This is so that services, deployments and ingresses don't clash. You can create a namespace with:

```bash
$ kubectl create namespace <your_namespace>
```

> TODO: switch context with kubectl

Since the CI cluster supports DNS, you can create an ingress file specific for CI:

```yaml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: dsp-hello-world-ingress
spec:
  rules:
  - host: dsp-hello-world-<day-month-year-random_number>.ci.notprod.homeoffice.gov.uk
    http:
      paths:
      - backend:
          serviceName: dsp-hello-world-service
          servicePort: 80
        path: /
```

At this point you can deploy the application with:

```bash
$ kubectl create -f kube/deployment.yaml
$ kubectl create -f kube/service.yaml
$ kubectl create -f kube/ingress-ci.yaml
```

The application is now available at [http://dsp-hello-world-<day-month-year-random_number>.notprod.homeoffice.gov.uk](http://dsp-hello-world-<day-month-year-random_number>.notprod.homeoffice.gov.uk).

You can dispose of your namespace with:

```bash
$ kubectl delete namespace <your_namespace>
```

## Deploying secrets

Your application is likely to have some parameters that are essential to the security of the application - for example API tokens and DB passwords. These should be stored as Kubernetes secrets to enable your application to read them. This process is described in the following guide.

See [official docs](http://kubernetes.io/docs/user-guide/secrets/#creating-a-secret-using-kubectl-create-secret) for more complete documentation; what follows is a very abridged version.

### Generate a strong secret

When generating passwords you should use the following code to ensure you are generating strong passwords.

```bash
LC_CTYPE=C tr -dc "[:print:]" < /dev/urandom | head -c 32
```

### Store some db credentials

The following file will create a kubernetes secret called `my-secret`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  dbhost: bXktcmRzLmV4YW1wbGUuY29t
  dbuser: {{.DB_USERNAME}}
  dbpass: {{.DB_PASSWORD}}
```

> *Please note* that you shouldn't commit passwords or sensitive information in your
> repository. We suggest you use environment variables to load secrets into the
> yaml file.

Secrets are passed to kubernetes as base64 encoded strings. The value for the `host` key is set to _my-rds.example.com_ in base64. You can encode and decode strings in base64 with:

```bash
echo -n my-rds.example.com | base64           # bXktcmRzLmV4YW1wbGUuY29t
echo bXktcmRzLmV4YW1wbGUuY29t | base64 -D     # my-rds.example.com
```

You can load secrets with:

```bash
<<<<<<< HEAD
export DB_USERNAME=$(echo -n my_username | base64)
export DB_PASSWORD=$(echo -n my_secure_password | base64)
kubectl create -f example-secrets.yaml
```

### See the stored secrets

```bash
kubectl describe secrets/my-secret
=======
kubectl create secret generic db-secrets \
  --from-literal=dbhost=my-rds.example.com \
  --from-literal=dbuser=myusername \
  --from-literal=dbpass=mypassword \
  --from-file=./certificate.pem
# ... repeat for each namespace with relevant permutations
​````

### See the stored secrets
​```bash
kubectl describe secrets/db-secrets
>>>>>>> 5a5c59f... temp: minikube
```

### Use the secrets

You can mount secrets and use them in your application by adding a `volumes`
section underneath `spec`:

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

You will find the nginx container comes up with a read only volume mounted at `/tmp/mysec` and the environment variable `PASSWORD` is set to `my_secure_password`.

### Debug with secrets

Sometimes your app doesn't want to talk to an API or a DB and you've stored the credentials or just the details of that in secret. 

```bash
kubectl exec -ti my-pod -c my-container -- mysql -h\$DBHOST -u\$DBUSER -p\$DBPASS
## or
kubectl exec -ti my-pod -c my-container -- openssl verify /secrets/certificate.pem
## or
kubectl exec -ti my-pod -c my-container bash
## and you'll naturally have all the environment variables set and volumes mounted.
## however we recommend against outputing them to the console e.g. echo $DBHOST
## instead if you want to assert a variable is set correctly use
[[ -z $DBHOST ]]; echo $?
## if it returns 1 then the variable is set.
```

## Debugging issues with your deployments to the platform

If you get to the end of the above guide but can't access your application there are a number of places something could be going wrong.
This section of the guide aims to give you some basic starting points for how to debug your application.

### Debugging deployments

We suggest the following steps:

#### 1. Check your deployment, replicaset and pods created proerly

```bash
$ kubectl get deployments
$ kubectl get rs
$ kubectl get pods
```

#### 2. Investigate potential issues with your pods (this is most likely)

If the get pods command shows that your pods aren't all running then this is likely where the issue is.
You can get further details on why the pods couldn't be deployed by running:

```bash
$ kubectl describe pods *pods_name_here*
```

If your pods are running you can check they are operating as expected by `exec`ing into them (this gets you a shell on one of your containers). 

```bash
$ kubectl exec -ti *pods_name_here* -c *container_name_here* bash
```

> **Please note** that the `-c` argument isn't needed if there is only one container in the pod.*

You can then try curling your application to see if it is alive and responding as expected. e.g.

```bash
$ curl localhost:4000
```

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
dsp-hello-world-3757754181-x1kdu   1/1       Running   2          6d
ingress-3879072234-5f4uq           1/1       Running   2          5d
```

You can attach to the running container with:

```bash
$ kubectl exec -ti <ingress-3879072234-5f4uq> bash
```

You're inside the container. You can cat the `nginx.conf` with:

```bash
$ cat /etc/nginx/nginx.conf
```

You can also inspect the logs with:

```bash
$ kubectl logs <ingress-3879072234-5f4uq>
```
