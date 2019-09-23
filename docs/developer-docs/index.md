# ACP Developer Documentation

## Introduction
ACP serves as a platform for teams to build and deploy projects in the Home Office. In addition to other technologies that we use, we strongly recommend to get an understanding of two of the core technologies that ACP is based on - Docker and Kubernetes:   

* [Docker](https://www.docker.com) is a software tool designed to make it easier to create, deploy and run applications by packaging up along with all its dependencies to containers.
* [Kubernetes](https://kubernetes.io) is an open-source platform for automating deployment, scaling,
and operations of application containers across clusters of hosts, providing container-centric infrastructure.

For further information on Docker and Kubernetes:   

* Docker
  * [Docker getting started tutorial](https://docs.docker.com/engine/getstarted/)  
* Kubernetes
  * [What is Kubernetes?](http://kubernetes.io/docs/whatisk8s/)  
  * [Kubernetes talk to introduce the concepts](https://www.youtube.com/watch?v=5gz8kOUstFc)

## Developer getting started guide
Some prerequisites are required before developing on ACP. [This guide](dev-setup.md) will show you how to:

  * Get access to the VPNs that allows you to connect to the platform
  * Get setup with the kubectl client that lets you deploy applications to kubernetes
  * Get access to Quay and Artifactory

In addition, new developers should look at the [new user flow](../newuser.md) documentation whilst going through this doc to serve as a checklist and make sure you are onboarded to all necessary platform services.

## Platform Hub
[The Platform Hub](https://hub.acp.homeoffice.gov.uk) serves as a central portal for users of ACP. It acts as an all-in-one place to find information, requests and also support for the platform. The hub also provides tools to develop, build, deploy and manage all your projects.

Updates are also on its way to include more self-service tools, along with documentation, FAQs and live status updates.
> Access to the Platform Hub requires the `Kube Platform` VPN profile. Please make sure you have followed the [Developer getting started guide](dev-setup.md) for instructions on connecting to VPNs.

## Support Portal
All support requests, changes, incidents and announcements for ACP are managed via [JIRA Service Desk](https://support.acp.homeoffice.gov.uk/servicedesk). A set of request templates have been created to cover a wide majority of general requests that users normally need. If your issue / request type is not listed, there is a [general request](https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/89) form available.

## Project getting started guide
Kubernetes resources (including your applications!) are always deployed into a particular namespace.
These namespaces provide separation between the different projects hosted on the platform.
A project service can have more than one namespace. For example, you can have namespaces that are different environments but are part of the same project service (e.g. dev and prod namespaces). Or if you have different namespaces that are all related to one project service (e.g. a web-api and an application namespace). For instructions on getting new namespaces and other relevant resources on getting started can be found below: [ACP How-to Docs](#ACP-How-to-Docs)

## ACP How-to Docs
The How To Docs within the ACP repo provides a collection of how-to guides for both Developers and DevOps to use [this](../how-to-docs/index.md)

## Developer guide to Continuous Integration with Drone
Drone is what we use for Continuous Integration in ACP. [This guide](../how-to-docs/drone-how-to.md) will cover how to use drone to test your PRs, build and push docker images, and to deploy.

## Writing Dockerfiles
[This guide](../how-to-docs/write-dockerfiles.md) covers best practice for building Dockerfiles, and lists our standard base images.
