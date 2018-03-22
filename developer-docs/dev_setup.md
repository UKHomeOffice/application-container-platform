# Developer setup guide

## Introduction

This guide aims to prepare developers to use the Application Container Platform. It is mandatory to work through this setup guide before attending the Developer Induction.

  1. [Set up GovWifi credentials](#connecting-to-govwifi)
  2. [Office 365](#office-365)
  3. [Connecting to ACP VPN](#connecting-to-acp-vpn)
  4. [Required binaries](#required-binaries)
  5. [Platform Hub registration](#platform-hub-registration)
  6. [User agreement](#user-agreement)


## Connecting to GovWifi

Please refer to [Connect to GovWifi] to obtain your credentials and set up wireless internet access via GovWifi.

## Office 365

Platform users must have Office 365 Single Sign-On (SSO) credentials for the `digital.homeoffice.gov.uk` domain. Please get in touch with your Programme Management Office to request an account or raise an issue on the [BAU] Board. If you can't access the Board, please ask a colleague to raise a request on your behalf. You will not be able to follow through the rest of this guide unless you have Office 365 credentials.

## Connecting to ACP VPN

Most of ACP's services operate behind a VPN which is accessible with an `openvpn` client. Instructions on installing `openvpn` for your OS can be found at [OpenVPN]

>Note: All examples in this document are for Linux distributions; instructions for other operating systems will vary.

Once you've got your Office 365 SSO credentials, you can now navigate to [Access ACP] and login with your Office 365 account by clicking on the link on the right.

Please download the VPN profile named **"ACP Platform (Ops, Dev, Ci, Test)"** and use the `openvpn` client to connect. Verify that you can resolve the [Platform Hub] before continuing on.

VPN profiles expire after 12 hours. You'll need to download and connect with a new VPN Profile when it expires.

## Required binaries

Before joining the Developer Induction, we kindly ask you to install binaries which are used for the deployment of applications in ACP - instructions on how to install these are shown below:

  - [Git](#git)
  - [Docker](#install-docker)
  - [Kubectl](#install-kubectl)
  - [Drone](#drone)
  - [KD](#kd)

#### Git

Verify if you have Git installed by:
```
$ git --version
git version 2.16.2
```
If Git is not installed, instructions on how to download and install it can be found over at the [Git website].

#### Install Docker

You can follow the instructions to install `docker` from the [Docker website]. You can verify the installation is successful with:

```bash
$ docker --version
Docker version 17.12.0-ce, build c97c6d6
```
#### Drone

Drone CLI can be downloaded from the [Drone CI website]. Instructions installing on multiple operating systems are shown on the webpage.

Verify that the installation is successful:

```bash
$ drone --version
drone version 0.8.0
```

#### KD

`kd` is minimalistic Kubernetes resource deployment tool that we use. You can get the latest version of kd on its [releases page].

Verify that the installation is successful:

```bash
$ kd -v
kd version v0.7.0
```

## Platform Hub Registration
> **Please note** that you need to have your VPN running to access the Platform Hub and also talk to cluster APIs.

You will need to register with the Platform Hub in order to gain access tokens for our Kubernetes clusters.
Head to [Platform Hub], you will need your O365 credentials to login/sign up. You will be asked to connect your Github account to your Platform Hub account - this will give you access to our [BAU] board, which is used to raise requests and issues regarding the Platform or your project. More information can be found in the [developer documentation].

Click on [Support Requests] under the`Help & Support` heading on the navigation bar after connecting your Github identity to the Hub. Create a support request for [Request access to Developer Induction]. The support request will be sent and reviewed by a member of ACP team. Updates on the request will be seen as a notification on your Github account.

Once created, your token will be shown under `Kubernetes` section of the [Connected Identities] tab on the sidebar. You can view all of your tokens by pressing the `Show Tokens` button.


#### Install kubectl

You can follow the instructions to install `kubectl` from the [Kubernetes website]. You can verify the installation is successful with:

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"7", GitVersion:"v1.7.3", GitCommit:"2c2fe6e8278a5db2d15a013987b53968c743f2a1", GitTreeState:"clean", BuildDate:"2017-08-03T07:00:21Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"linux/amd64"}
```

#### Connecting to the cluster

In order to access a namespace you will need to configure `kubectl` to connect to our clusters - instructions on setting it up can be found on the `Set up Kube Config` button on the [Connected Identities] page.

Verify that your `kubectl` is configured properly by trying to list pods and secrets in the `acp-induction` namespace:

```bash
$ kubectl --context=acp-notprod_ACP --namespace=acp-induction get pods
No resources found.
$ kubectl --context=acp-notprod_ACP --namespace=acp-induction get secrets
NAME                  TYPE                                  DATA      AGE
default-token-dcnmg   kubernetes.io/service-account-token   3         105d
```
>The output of the command above may differ if there are other pods or extra secrets deployed to the namespace.

## User agreement

Finally, please head over and read through our [SLA] documentation to familiarise yourself with the level of service ACP provides to its users including the level and hours of support on offer and issue escalation procedures.

[Access ACP]:https://access-acp.digital.homeoffice.gov.uk
[Connect to GovWifi]:https://www.gov.uk/government/collections/connect-to-govwifi
[OpenVPN]:https://openvpn.net/index.php/open-source/downloads.html
[Git website]:https://git-scm.com/
[Docker website]:https://docs.docker.com/engine/installation/
[Kubernetes website]:http://kubernetes.io/docs/user-guide/prereqs/
[Drone CI website]:http://docs.drone.io/cli-installation/
[releases page]:https://github.com/UKHomeOffice/kd/releases
[Platform Hub]:https://hub.acp.homeoffice.gov.uk/
[developer documentation]:https://github.com/UKHomeOffice/application-container-platform/tree/master/developer-docs#platform-hub
[BAU]:https://github.com/UKHomeOffice/application-container-platform-bau/
[Support Requests]:https://hub.acp.homeoffice.gov.uk/help/support/requests/overview
[Request access to Developer Induction]:https://hub.acp.homeoffice.gov.uk/help/support/requests/new/dev-induction-token
[Connected Identities]:https://hub.acp.homeoffice.gov.uk/identities
[SLA]:https://github.com/UKHomeOffice/application-container-platform/blob/master/sla.md
