# Developer Guide to application deployment

## Introduction
This guide is aimed at developers that have already completed the [initial setup](./dev_setup.md). It gives them advice on how to go about deploying applications

The most important things are to:
1. Get to know docker by reading [the docs](https://docs.docker.com/) 
2. Get to know kubernetes by reading [the docs](http://kubernetes.io/v1.1/basicstutorials.html)
3. Get your application running in a docker container
4. Setup automatic docker build jobs with quay.io
5. Assign a node port
6. Define the replication controllers for your application
7. Define the services for your application
8. Deploy!
9. Elastic Load Balancer (ELB)

Currently CI systems are still broadly handled on a per project basis whilst we standardise. In time there will be a self-service way to setup your CI as well.

### Getting to know docker
We strongly recommend getting to know docker. We build all of our applications into docker images, which contain all dependencies for the app. This has huge benefits in terms of making our deployments repeatable. It also means there is just 1 main artifact which can be used for deploys.

Especially important is that you familiarise yourself with the documentation on Dockerfiles
 
### Getting to know kubernetes
Again it is well worth getting to know Kubernetes by reading the docs. Some of the key concepts include:
- A pod is a collection of containers that typically rely on each other, similar to using docker link. All containers in a pod will be deployed onto the same host
- A replication controller manages a group of identical pods, and ensures there is always the specified number of healthy pods
- A service exposes a given port on the host machine to the outside world, allowing people to communicate with your application

## Dockerise your application
To dockerise your application so that it can run with docker you will need to create a Dockerfile, typically created in the root directory of your project.

All Dockerfiles should use the standard Home Office base image. This is so that patching can be done quickly and easily across the organisation. The Home Office base image is located [here](https://quay.io/repository/ukhomeofficedigital/docker-centos-base)

## Setup automatic docker build jobs with quay.io
quay.io has 2 main uses:

1. quay.io can automatically build your docker images, giving you confidence that they build properly
2. quay.io is also a docker repository, allowing you to use the built images for your deploys

quay.io has documentation for how to set up a new build job. Note you will need to link it to your github account in order for this to work.

You will need to set up a new repository on quay.io that automatically builds your application. Please use github tags to create tagged images in quay. Versioning of images is extremely important!!

*IMPORTANT NOTE* - Currently quay.io only works with Github, not Gitlab. If you are using Gitlab please contact the dev ops team to make alternative arrangements for how we can build your images.

## Assigning a node port
Each service running on the platform needs a unique port that the service will be exposed on. The dev ops team manages these ports and so one must be requested before deploying your application.

Currently assigned node ports can be found [here](./apps_deployment.md)

To request a node port simply log an issue [here](https://github.com/UKHomeOffice/dsp/issues)

## Define kubernetes replication controllers for your application
TODO: Look at what the port restrictions are and what the process is for this.
Now that you have docker images being stored for your application in quay.io you need a file to tell kubernetes which images to deploy, how many images you want, and several other parameters they may need to know about (for oexample environment variables)

## Define kubernetes services for your application
You will also need a services file that tells Kubernetes how to expose your application to the outside world. You  must use the node port you have been assigned.

## Deploy
Using the kubectl tool deploy your replication controller and your service!

If this is the first time you've done this you will need to run:
```bash
kubectl create -f my-replication-controller.yaml
kubectl create -f my-service.yaml
```

If you have run this before you will need to perform a rolling update:
```bash
kubectl rolling-update my-controller-name -f my-replication-controller.yaml
```
Note that for a rolling update the name of the replication controller must be updated so that it is unique. This is because a rolling update does a safe update, where it temporarily runs both old and new versions of the application in parallel.

For a more sophisticated deployment tool that allows templating of your deployment files check out [kb8or](https://github.com/UKHomeOffice/kb8or).

## Elastic load balancer
Although your service is now exposed on the Kubernetes cluster, it is not actually exposed to the outside world. This is a one off task and is not currently self-service.

An ELB needs to be created. In order to have one created log an issue [here](https://github.com/UKHomeOffice/dsp/issues). Make sure to include the port number your service is running on, and the DNS name you wish to give your service.

## Done!
Your service should now be up and running! For future updates you will just need to update your replication controllers with a rolling update to use the version of the image you want.