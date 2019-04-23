# Developer setup guide
## Introduction

This guide aims to prepare developers to use the Application Container Platform. You must complete the steps below before attending the ACP Induction.

All examples in this document are for Linux distributions and instructions for other operating systems will vary. If you choose to use a Windows device, please ensure that [Windows Subsystem for Linux] is installed.

  1. [Set up GovWifi credentials](#connecting-to-govwifi)
  2. [Office 365](#office-365)
  3. [Connecting to ACP VPN](#connecting-to-acp-vpn)
  4. [Platform Hub registration](#platform-hub-registration)
  5. [Add a ssh key to Gitlab](#add-a-ssh-key-to-gitlab)
  6. [Required binaries](#required-binaries)
  7. [User agreement](#user-agreement)


## Connecting to GovWifi

Please refer to [Connect to GovWifi] to obtain your credentials and set up wireless internet access via GovWifi.

## Office 365

Platform users must have Office 365 Single Sign-On (SSO) credentials for the `digital.homeoffice.gov.uk` domain. Please get in touch with your Programme Management Office to request an account or raise an issue on the [Support Portal]. If you can't access the Board, please ask a colleague to raise a request on your behalf. You will not be able to follow through the rest of this guide unless you have Office 365 credentials.

## Connecting to ACP VPN

Most of ACP's services operate behind a VPN which is accessible with an `openvpn` client. Instructions on installing `openvpn` for your OS can be found at [OpenVPN]

Once you've got your Office 365 SSO credentials, you can now navigate to [Remote Access] and login with your Office 365 account by clicking on the link on the right.

Please download the VPN profile named **"ACP Platform (Ops, Dev, CI, Test)"** and use the `openvpn` client to connect. Verify that you can resolve the [Platform Hub] before continuing on.

VPN profiles expire after 12 hours. You'll need to download and connect with a new VPN Profile when it expires.

## Platform Hub registration
> **Please note** that you need to have your VPN running to access the Platform Hub and also talk to cluster APIs.

You will need to register with the Platform Hub in order to gain access tokens for our Kubernetes clusters.
Head to [Platform Hub], you will need your O365 credentials to login/sign up. You will be asked to connect your Github account to your Platform Hub account. This will give you access to project repositories under the UKHomeOffice Organisation in GitHub.

Navigate to the [Support Portal] (JIRA Service Desk), logging in via your O365 account, and create a support request for [access to Developer Induction]. The support request will be sent to and reviewed by a member of the ACP team. Any updates on the request will be available to view within the [Support Portal] and additionally emailed to you.

Once created, your token will be shown in the [Platform Hub] under the `Kubernetes` section of the [Connected Identities] tab on the sidebar. You can view all of your tokens by pressing the `Show Tokens` button.

## Add a ssh key to Gitlab

You will need to add a ssh public key to your Gitlab profile before attending the Induction. Please sign into [Gitlab] with Office 365 and add a ssh public key to your profile. Instructions for generating a ssh keypair can be found in [Gitlab Docs].

## Required binaries

Before joining the Developer Induction, we kindly ask you to install binaries which are used for the deployment of applications in ACP - instructions on how to install these are shown below:

  - [Git](#install-git)
  - [Docker](#install-docker)
  - [Drone](#install-drone)
  - [Kubectl](#install-kubectl)
  - [AWS CLI](#install-aws-cli)

#### Install Git

Verify if you have Git installed by:
```
$ git --version
git version 2.16.2
```
If Git is not installed, instructions on how to download and install it can be found over at the [Git website].

> **Please note** We assume a basic knowledge of Git for the ACP Induction. If you've not used git before, or need to brush up on your skills please see [Git basics].

#### Install Docker

You can follow the instructions to install `docker` from the [Docker website]. You can verify the installation is successful with:

```bash
$ docker --version
Docker version 18.03.1-ce, build 9ee9f40

# version 17.06 or above is required
```
#### Install Drone

Drone CLI can be downloaded from the [Drone CI website]. Instructions installing on multiple operating systems are shown on the webpage. Currently our drone instance is compatible with `drone 0.8.6`, which can be found [here](https://github.com/drone/drone-cli/releases/tag/v0.8.6)

Verify that the installation is successful:

```bash
$ drone --version
drone version 0.8.6
```

#### Install Kubectl

You can follow the instructions to install version 1.8 of `kubectl` from the [Kubernetes website]. You can verify the installation is successful with:

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"8", GitVersion:"v1.8.4", GitCommit:"9befc2b8928a9426501d3bf62f72849d5cbcd5a3", GitTreeState:"clean", BuildDate:"2017-11-20T05:28:34Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"linux/amd64"}
```

#### Install AWS CLI

Follow the [official AWS documentation] for instructions to install the AWS CLI. You can verify the installation is successful with:

```bash
$ aws --version
aws-cli/1.16.28 Python/2.7.10 Darwin/18.2.0 botocore/1.12.18

# version 1.11.91 or above is required
```

#### Connecting to the cluster

In order to access a namespace you will need to configure `kubectl` to connect to our clusters - instructions on setting it up can be found on the `Set up Kube Config` button on the [Connected Identities] page.

Verify that your `kubectl` is configured properly by trying to list pods and secrets in the `acp-induction` namespace:

```bash
$ kubectl --context=acp-notprod_acp-induction --namespace=acp-induction get pods
No resources found.
$ kubectl --context=acp-notprod_acp-induction --namespace=acp-induction get secrets
NAME                  TYPE                                  DATA      AGE
default-token-dcnmg   kubernetes.io/service-account-token   3         105d
```
>The output of the command above may differ if there are other pods or extra secrets deployed to the namespace.

## User agreement

Finally, please head over and read through our [SLA] documentation to familiarise yourself with the level of service ACP provides to its users including the level and hours of support on offer and issue escalation procedures.

[Remote Access]:https://remote-access.vpn.acp.homeoffice.gov.uk
[Windows Subsystem for Linux]:https://docs.microsoft.com/en-us/windows/wsl/about
[Connect to GovWifi]:https://www.gov.uk/government/collections/connect-to-govwifi
[OpenVPN]:https://openvpn.net/index.php/open-source/downloads.html
[Git website]:https://git-scm.com/
[Git basics]:https://git-scm.com/book/en/v2/Getting-Started-Git-Basics
[Gitlab]:https://gitlab.digital.homeoffice.gov.uk
[Gitlab Docs]:https://docs.gitlab.com/ee/ssh/
[Docker website]:https://docs.docker.com/engine/installation/
[Kubernetes website]:http://kubernetes.io/docs/user-guide/prereqs/
[Drone CI website]:http://docs.drone.io/cli-installation/
[releases page]:https://github.com/UKHomeOffice/kd/releases
[Platform Hub]:https://hub.acp.homeoffice.gov.uk/
[developer documentation]:https://github.com/UKHomeOffice/application-container-platform/tree/master/developer-docs#platform-hub
[Support Portal]:https://support.acp.homeoffice.gov.uk/servicedesk
[access to Developer Induction]:https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/94
[Connected Identities]:https://hub.acp.homeoffice.gov.uk/identities
[SLA]:https://gitlab.digital.homeoffice.gov.uk/acp-docs/acp-support
[official AWS documentation]:https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
