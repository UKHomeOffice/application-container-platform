# Developer Introduction to the Platform

## Introduction
This guide is aimed at developers that have already completed the [initial setup](./dev_setup.md).
It covers how to manually deploy an application to the platform, and some advice for debugging applications on the platform.

1. [Deploying an application to the platform](#deploying-an-application-to-the-platform)
2. [Debugging issues with your application](#debugging-issues-with-your-deployments-to-the-platform)

## Deploying an application to the platform
For this demo we will use a simple nodejs application:  
https://github.com/UKHomeOffice/docker-node-hello-world

Please clone this repo before getting started:

```bash
git clone https://github.com/UKHomeOffice/docker-node-hello-world
```

The stages involved in deploying an application are:

1. [Dockerise your application](#dockerise-your-application) (the example above is already Dockerised)
2. [Build and tag your docker image](#build-and-tag-your-docker-image)
3. [Push the docker image to a docker repository](#push-the-docker-image-to-a-repository)
4. [Tell Kubernetes to deploy your docker image](#tell-kubernetes-to-deploy-your-docker-image)
    1. [Define a deployment for your application](#define-a-deployment-for-your-application)
    2. [Run the deployment](#run-the-deployment)
5. [Expose your application externally](#expose-your-application)
    1. [Define a service which exposes your application inside the platform](#define-a-service-for-your-application)
    2. [Use an ingress controller which exposes your service externally](#exposing-your-service-externally)
6. [Store and manage secrets](#secrets)
    1. [Generate a strong secret](#generate-a-strong-secret)
    2. [Store some db credentials](#store-some-db-credentials)
    3. [See the stored secrets](#See-the-stored-secrets)
    4. [Use the secrets](#use-the-secrets)
    5. [Debug with secrets](#debug-with-secrets)
7. [Delete all your hard work](#deleting-deployed-resources)

### Dockerise your application
The demo application is already dockerised. If you are dockerising a different application please follow the Home Office guidance [here](./writing_dockerfiles.md)

### Build and tag your docker image
To build and tag your docker image use the standard docker commands:

```bash
cd docker-node-hello-world
docker build -t quay.io/ukhomeofficedigital/induction-hello-world:tim .
```

*IMPORTANT NOTE:* Please give your image a unique tag (e.g. using your name) so we don't get lots of clashes!

### Push the docker image to a repository
Before deploying the docker image must be stored in either the ukhomeofficedigital quay or on our internal artifactory.
The tag used when building your docker image must match the repository you want to push for. e.g.

```bash
docker push quay.io/ukhomeofficedigital/induction-hello-world:tim
```

### Tell Kubernetes to deploy your docker image

Before using the kubernetes cluster you will need to be on the [VPN](https://sso.digital.homeoffice.gov.uk/auth/realms/hod-vpn/protocol/openid-connect/auth?client_id=broker&redirect_uri=https%3A%2F%2Fauthd.digital.homeoffice.gov.uk%2Foauth%2Fcallback&response_type=code&scope=vpn-user+openid+email+profile&state=%2F).

You can deploy a number of different types of resource to kubernetes using the kubectl client.

For each resource type you will first need to define a yaml file detailing the resource to deploy, you can then deploy it.

### Define a deployment for your application
A deployment defines what application you want to run (which can consist of multiple containers) and how many replicas you want.

An example deployment file is given [here](./resources/example-deployment.yaml).
It includes a hello-world container and an nginx container terminating TLS - a very common pattern that we recommend. 
Please use this as a basis for your own deployment, but **replacing any names with one unique to you**. These include:

- metadata.name
- spec.template.metadata.labels.name
- the image tag to deploy

### Run the deployment

Call your deployment file *my-deployment.yaml* and save it to your current directory.

You can then deploy your deployment to kubernetes by running:

```bash
kubectl create -f my-deployment.yaml
```

More documentation on deployments is available from kubernetes [here](http://kubernetes.io/docs/user-guide/deployments/)

### What has the deployment done?
You should now have a deployment in kubernetes. This in turn creates a replica set, which in turn creates pods. You can validate all is working properly by running:
```bash
kubectl get deployments
kubectl get rs
kubectl get pods
```

There is a troubleshooting section further on about how to debug any issues you may encounter.

### Expose your application
To expose your application externally you will need to create a service and an ingress controller for it.
The service will expose your application within the kubernetes cluster and the ingress controller will expose your service to the outside world.

### Define a service for your application
Your application is now running, but nothing can talk to it! For it to be exposed you first need to create a service.
This exposes your service to the rest of the kubernetes cluster.

An example service file is given [here](./resources/example-service.yaml). Please use this as a basis for your own service, 
but **replacing any names with one unique to you**. 
These include:

- metadata.name
- spec.selector.name

Call your service file *my-service.yaml* and save it to your current directory.

You can then deploy your service to kubernetes by running:

```bash
kubectl create -f my-service.yaml
```

You can verify your service has been created by running:

```bash
kubectl get services
```

### Exposing your service externally
For external facing services you will then need to create an ingress controller. This instructs kubernetes how to expose a service to the outside world.
An [example ingress file is given here](./resources/example-ingress.yaml). Please use this as a basis for your own ingress controller, 
but **replacing any names with one unique to you**. These include:

- spec.rules.http.paths.backend.serviceName
- spec.rules.host

The ingress file specifies one annotations which is worth understanding:

* *ingress.kubernetes.io/secure-backends: "true"* - This annotation tells the platform that your service is serving HTTPS. 
  This is typically the case as it means traffic between nodes in the kubernetes cluster is all encrypted, which helps it to be more secure 

Call your ingress file *my-ingress.yaml* and save it to your current directory.

You can then deploy your ingress to kubernetes by running:

```bash
kubectl create -f my-ingress.yaml
```

You can verify that your ingress resource has been created by running:

```bash
kubectl get ingress
```

You should also now be able to go to the unique url specified in your ingress resource and see your application running.

More documentation on ingress is available from kubernetes [here](http://kubernetes.io/docs/user-guide/ingress/)

### Secrets

Your application is likely to have some parameters that are essential to the security of the application - for example API tokens and DB passwords. These should be stored as Kubernetes secrets to enable your application to read them. This process is described in the following guide.

See [official docs](http://kubernetes.io/docs/user-guide/secrets/#creating-a-secret-using-kubectl-create-secret) for more complete documentation; what follows is a very abridged version.

#### Generate a strong secret
When generating passwords you should use the following code to ensure you are generating strong passwords.
```bash
LC_CTYPE=C tr -dc "[:print:]" < /dev/urandom | head -c 32
```

#### Store some db credentials
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
export DB_USERNAME=$(echo -n my_username | base64)
export DB_PASSWORD=$(echo -n my_secure_password | base64)
kubectl create -f example-secrets.yaml
```

#### See the stored secrets
```bash
kubectl describe secrets/my-secret
```

#### Use the secrets
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

#### Debug with secrets
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

### Deleting deployed resources
After the induction please delete everything you have deployed so as to not clutter up the platform.

The best way to delete any deployed resources is to first get them to check the names, then delete. e.g.
```bash
kubectl get deployments
kubectl delete deployment my-deployment
```

## Debugging issues with your deployments to the platform
If you get to the end of the above guide but can't access your application there are a number of places something could be going wrong.
This section of the guide aims to give you some basic starting points for how to debug your application.

### Debugging deployments
We suggest the following steps:

#### 1. Check your deployment, replicaset and pods created proerly
```bash
kubectl get deployments
kubectl get rs
kubectl get pods
```

#### 2. Investigate potential issues with your pods (this is most likely)
If the get pods command shows that your pods aren't all running then this is likely where the issue is.
You can get further details on why the pods couldn't be deployed by running:

```bash
kubectl describe pods *pods_name_here*
```

If your pods are running you can check they are operating as expected by execcing into them (this gets you a shell on one of your containers). 

```bash
kubectl exec -ti *pods_name_here* -c *container_name_here* bash
```
*NB: The -c argument isn't needed if there is only one container in the pod.*

You can then try curling your application to see if it is alive and responding as expected. e.g.

```bash
curl localhost:4000
```

#### 3. Investigate potential issues with your service
A good way to do this is to run a container in your namespace with a bash terminal:

```bash
kubectl run -ti --image quay.io/ukhomeofficedigital/centos-base debugger bash
```

From this container you can then try curling your service. Your service will have a nice DNS name by default, so you can for example run:

```bash
curl my-service-name
```

#### 4. Investigate potential issues with ingress
At the moment we recommend asking a friendly [dev ops](https://hod-dsp.slack.com/archives/general) for help with these issues!
