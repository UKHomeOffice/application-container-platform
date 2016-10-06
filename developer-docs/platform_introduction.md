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
4. [Tell Kubernetes to deploy your docker image](#tell-Kubernetes-to-deploy-your-docker-image)
    1. Define a deployment for your application
    2. Run the deployment
5. [Expose your application externally](#expose-your-application)
    1. Define a service which exposes your application inside the platform
    2. Use an ingress controller which exposes your service externally

## Dockerise your application
The demo application is already dockerised. If you are dockerising a different application please follow the Home Office guidance [here](./writing_dockerfiles.md)

## Build and tag your docker image
To build and tag your docker image use the standard docker commands:

```bash
cd docker-node-hello-world
docker build -t quay.io/ukhomeofficedigital/induction-hello-world:tim .
```

*IMPORTANT NOTE:* Please give your image a unique tag (e.g. using your name) so we don't get lots of clashes!

## Push the docker image to a repository
Before deploying the docker image must be stored in either the ukhomeofficedigital quay or on our internal artifactory.
The tag used when building your docker image must match the repository you want to push for. e.g.

```bash
docker push quay.io/ukhomeofficedigital/induction-hello-world:tim
```

## Tell Kubernetes to deploy your docker image

You can deploy a number of different types of resource to kubernetes using the kubectl client.

For each resource type you will first need to define a yaml file detailing the resource to deploy, you can then deploy it.

### Define a deployment for your application
A deployment defines what application you want to run (which can consist of multiple containers) and how many replicas you want.

An example deployment file is given [here](./resources/example-deployment.yaml).
It includes a hello-world container and an nginx container terminating TLS - a very common pattern that we recommend. 
Please use this as a basis for your own deployment, but replacing any names with one unique to you.
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

## Expose your application
To expose your application externally you will need to create a service and an ingress controller for it.
The service will expose your application within the kubernetes cluster and the ingress controller will expose your service to the outside world.

### Define a service for your application
Your application is now running, but nothing can talk to it! For it to be exposed you first need to create a service.
This exposes your service to the rest of the kubernetes cluster.

An example service file is given [here](./resources/example-service.yaml). Please use this as a basis for your own service, but replacing any names with one unique to you.
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
An example ingress file is given [here](./resources/example-ingress.yaml). Please use this as a basis for your own ingress controller, but replacing any names with one unique to you.

The ingress file specifies 2 annotations which are worth understanding:

* *kubernetes.io/tls-acme: "true"* - This annotation tells the platform to automatically generate TLS certificates (for HTTPS) if they don't already exist. 
If you don't have this setting you will need to create your own kubernetes secret with TLS certificates in your namespace. 
Note the secretName at the bottom must be unique
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

### 4. Investigate potential issues with ingress
At the moment we recommend asking a friendly dev ops for help with these issues!
