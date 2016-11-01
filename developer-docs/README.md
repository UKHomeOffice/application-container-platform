# HOD DSP Developer Documentation

## Before you start
We strongly recommend getting to know Docker and Kubernetes - the 2 core technologies that the platform is based around.
[Docker] is a tool for building and managing containers
[Kubernetes](http://kubernetes.io/docs/whatisk8s/) is an open-source platform for automating deployment, scaling,
and operations of application containers across clusters of hosts, providing container-centric infrastructure.

Some [recommended resources for Docker and Kubernetes are available here](./recommended-reading.md)

## Projects and namespaces
Kubernetes resources (including your applications!) are always deployed into a particular namespace. 
These namespaces provide separation between the different projects hosted on the platform.
We also recommend that each project has one namespace per environment (e.g. for dev, preprod, prod)

## Project getting started guide
For new projects you will need to put a PR into the hosting platform to create new namespaces.
Instructions are available here:  
https://gitlab.digital.homeoffice.gov.uk/Devops/kube-hod-platform

We recommend you have one per environment, with each namespace prefixed with the project name. 
For example if the project name were *boomba* the namespaces might be *boomba-dev*, *boomba-uat*, *boomba-preprod*.

You will also need to ask for your team to be granted access to the new namespaces, which you can do by making a request here:  
https://github.com/UKHomeOffice/hosting-platform-bau/projects/1

## Project getting to production guide
Content to follow soon! In the meantime please ask for help in the Devops channel on the [HOD DSP Slack](https://hod-dsp.slack.com)

## Developer getting started guide
[This guide](dev_setup.md) shows you how to:

* Get access to the VPN that allows you to connect to the platform
* Get setup with the kubectl client that lets you deploy applications to kubernetes
* Get access to Quay and Artifactory

## Developer application deployment guide
[This guide](platform_introduction.md) takes you through deploying a demo application to the platform, and explains some basic steps you can take to debug applications on the platform

## Writing Dockerfiles
[This guide](./writing_dockerfiles.md) covers best practice for building Dockerfiles, and lists our standard base images.

## How to setup a build monitor
[This guide](build_monitors.md) covers how to set up a build monitor.
