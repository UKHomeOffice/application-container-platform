# Developer setup guide

## Pre-requisites

You should already have access to Github with membership of the UKHomeOffice org.

## Introduction

This guide is aimed at developers that want to start using the platform to host their application.

1. [Connect to VPN](#connect-to-vpn)
2. [Install docker](#install-docker)
3. [Install and configure kubectl](#install-and-configure-kubectl)
4. [Install minikube](#install-minikube)
5. [Quay access](#quay-access)
6. [Artifactory access](#artifactory-access)

## Connect to the VPN

Once you've got an Office 365 Account you can now navigate to [https://authd.digital.homeoffice.gov.uk](https://authd.digital.homeoffice.gov.uk) and login with your Office 365 account by clicking on the 365 link on the right.

Once you're logged in please download the VPN profile called _"DSP Platform Dev, CI, Ops"_ from under VPN Profiles.

You can connect to the vpn using `openvpn`.  You can follow the instruction to install `openvpn` from the [OpenVPN website](https://openvpn.net/index.php/open-source/downloads.html).

You can verify the installation was successful with:

```bash
$ openvpn --version
OpenVPN 2.3.13 x86_64-apple-darwin16.1.0 [SSL (OpenSSL)] [LZO] [MH] [IPv6] built on Nov  5 2016
```

You can connect to the VPN using the profile downloaded at the previous step with:

```bash
$ sudo openvpn --config <vpn_profile_file>
Tue Dec  6 11:24:04 2016 Initialization Sequence Completed
```

The profile expires after 12 hours. You'll need to download and connect to a new VPN Profile when it expires.

## Install Docker

You can follow the instructions to install `docker` from the [Docker website](https://docs.docker.com/engine/installation/). You can verify the installation is successful with:

```bash
$ docker --version
Docker version 1.12.3, build 6b644ec
```

## Install and configure kubectl

### Install kubectl

You can follow the instructions to install `kubectl` from the [Kubernetes website](http://kubernetes.io/docs/user-guide/prereqs/). You can verify the installation is successful with:

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"4", GitVersion:"v1.4.6+e569a27", GitCommit:"e569a27d02001e343cb68086bc06d47804f62af6", GitTreeState:"not a git tree", BuildDate:"2016-11-12T09:26:56Z", GoVersion:"go1.7.3", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"4", GitVersion:"v1.4.5", GitCommit:"5a0a696437ad35c133c0c8493f7e9d22b0f9b81b", GitTreeState:"clean", BuildDate:"1970-01-01T00:00:00Z", GoVersion:"go1.7.1", Compiler:"gc", Platform:"linux/amd64"}
```

### Configure kubectl

You will need to configure the `kubectl` client with the appropriate details to be able to talk to the kubernetes cluster.
We recommend copying the [example kubectl config](resources/kubeconfig) to `~/.kube/config`. Note that you may need to create this directory and file.

The only change you will need to make is to replace _"XXXXXXXXXX"_ with your kubernetes token.

You can submit a request to obtain a kubernetes token by adding an issue to the Hosting Platform Bau project on Github [here](https://github.com/UKHomeOffice/hosting-platform-bau/issues).

Please use the below template for your request:

```
Please can I have a kubernetes token with access to my teams namespaces.  
Email: xxx.xxx@digital.homeoffice.gov.uk  
Name: xxx xxx  
Team: My Project Team  
Public GPG Key: xxxxxxxxx
Namespace: dev-induction
```

You need to provide your public gpg key as the kube token you receive back will be encrypted using it.
If you need to, you can [generate a gpg key](https://help.github.com/articles/generating-a-new-gpg-key/).

### Use kubectl

You can verify the installation is successful with:

```bash
$ kubectl get pods
```

> **Please note** that you need to have your VPN running to talk to the kubernetes cluster.

You should get an empty reply with just some column headers. The config file by default looks only at the *dev-induction* namespace.
To look at other namespace you can, for example do:

```bash
$ kubectl --namespace=my-namespace get pods
```
You can also edit your kubernetes config, either by editing the file directly or by running:

```bash
$ kubectl config
```

## Install minikube

You can follow the instruction to install `minikube` from the [Minikube website](https://github.com/kubernetes/minikube/releases).

> **Please note** that you have to have kubectl installed before you can run minikube.

If the installation is successful, you can run minikube locally with:

```bash
$ minikube start
Starting local Kubernetes cluster...
Kubectl is now configured to use the cluster.
```

## Quay access

We use [quay](https://www.quay.io) for storing public docker images. Please login to quay with your Github account and create a password for your account (accounts created by signing in with Github don't have a password by default). You are not able to publish docker images to the UKHomeOffice organisation unless you request access to it.

You can submit a request to be part of the UKHomeOffice organisation on quay by adding an issue to the Hosting Platform Bau project on Github [here](https://github.com/UKHomeOffice/hosting-platform-bau/issues).

Please use the below template for your request:

```
Please can I be added to the UKHomeOffice organisation in quay.  
Quay username: xxx
Name: xxx xxx
Team: My Project Team  
```

You have to login to be able to push docker images from your local machine to quay:

```bash
$ docker login quay.io
```

> **Please note** that quay doesn't create a password by default when you log in using Github. You need to create a password in order to log in into quay.

As all of our repositories are public you can then pull any of them. [Here are our Home Office quay repos](https://quay.io/organization/ukhomeofficedigital).

## Artifactory access

[Our private Artifactory is available here](https://artifactory.digital.homeoffice.gov.uk/artifactory/webapp/#/login).
We use this for storing private docker images and other private artefacts (e.g. JARs, node modules, etc).

When logging in please use the **HOD SSO** sign in option. To pull images from Artifactory you will need to do a docker login.
Your username will be your digital email address and you can
[generate an API key to use as your password here](https://artifactory.digital.homeoffice.gov.uk/artifactory/webapp/#/profile).

```bash
$ docker login docker.digital.homeoffice.gov.uk
```

Images can be pulled with:

```bash
$ docker pull docker.digital.homeoffice.gov.uk/aws-dsp:v0.1.3-rc1
```

If you get this error instead:

```
Error: Status 400 trying to pull repository aws-dsp: "{\n  \"errors\" : [ {\n    \"status\" : 400,\n    \"message\" : \"Unsupported docker v1 repository request for 'docker'\"\n  } ]\n}"
```

You haven't logged in successfully.