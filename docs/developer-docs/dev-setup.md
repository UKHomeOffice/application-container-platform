# Developer Onboarding Guide
## Introduction

This guide ensures your device satisfies the requirements for the ACP Induction.  Together these comprise the onboarding process for developers, providing overviews of ACP and how the Home Office uses its services. If you are a developer whose team uses ACP, you should complete this guide and then the induction.

Sign up for the induction [here][induction_signup]. After you sign up, a member of the ACP team will contact you to confirm your place and provide the induction material. Once the induction begins, you have a fixed amount of time to complete it.

A week before your confirmed induction date you can request the ACP Induction material from [ACP Support][induction_material].

You should complete each step of this guide before attending the induction. All examples in this document are for Linux distributions; instructions for other operating systems may vary. If you are using a Windows device, ensure that [Windows Subsystem for Linux][https://docs.microsoft.com/en-us/windows/wsl/about] is installed on it.

## Internet access

To complete this guide you require an active internet connection. If you are working from a government office building, see [Connect to GovWifi][govwifi] to obtain your credentials and set up wireless internet access via GovWifi. If you are working remotely, ensure you have secure internet access from your location.

## Obtain Office 365 credentials

ACP users require Office 365 Single Sign-on (SSO) credentials for the digital.homeoffice.gov.uk domain. To request an account, contact your Programme Management Office.

## Connect to ACP VPN

Most of ACP's services operate behind a VPN, accessible using a VPN client. We recommend using OpenVPN. See OpenVPN for instructions on how to download and install [OpenVPN][openvpn].

Using your Office 365 SSO credentials, sign in to [Remote Access][remote_access]. Download the **Default** version of the kube-platform VPN profile and connect to it using your VPN client. Profiles expire after 72 hours, after which you must download and connect to a new kube-platform profile to continue accessing ACP services.

To ensure your VPN connection is configured correctly, verify you can access [ACP Hub][acp_hub]. If you cannot access ACP Hub or other ACP services, such as Sysdig, while connected to the VPN, set your DNS servers to 8.8.8.8 (Google's DNS servers). If the issue persists, raise an issue on [ACP Support][acp_support].

## Register on ACP Hub
After connecting to the kube-platform profile, use your Office 365 credentials to register on [ACP Hub][acp_hub]. The Hub provides a central portal where you can connect your identities for ACP services, manage projects and self-serve Kubernetes tokens.

When prompted, connect your GitHub account to your Platform Hub account. This grants you direct access to project repositories under the UKHomeOffice Organisation on GitHub.

## Acquire a Kubernetes token

To complete the ACP induction, you require an access token for ACP Kubernetes clusters. On [ACP Support][acp_support], raise a request for ACP Induction access. If you cannot access the Portal, ask one of your team members with access to raise a request to add you to the service desk first.

A member of the ACP Support team will receive and review your request. ACP Support emails notifications of request updates; you can also sign in to ACP Support to view updates. If you have an AD-only email account (a digital account without a mailbox), you can request to receive the notifications at an alternative email address [here][email_update].

Once your request is approved, a token will be generated for you. You can view it on the [Connected Identities][connected_ids] page.

## Add an SSH key to GitLab

You require basic knowledge of Git workflows for the ACP induction. See the [Git documentation][git_basics] for an overview.

To access some of the induction material, you need to add an SSH public key to your GitLab profile. Sign in to GitLab with your Office 365 credentials and generate an SSH keypair, then add the public key to your profile. See the [GitLab documentation][gitlab_docs] for instructions.

## Sign in to Sysdig

Use your Digital Home Office account credentials to access our [Sysdig instance][acp_sysdig]. Select **OpenID** and then **O365** to sign in.

Sysdig automatically adds you to a default team that does not have access to any data, however a member of the ACP team will add you to the ACP Induction team shortly before the induction.

## Join the HOD-DSP Slack workspace

You can join [our Slack workspace][acp_slack] using a Home Office email address. Note that the signup process requires inbox access; if you have an AD-only Digital account, raise a request on [ACP Support][acp_support] to have your corporate email invited to the HOD-DSP workspace.

Once you have access to the workspace, join the following channels:
  * #acp-induction: to communicate with the ACP team and other users completing the induction
  * #acp-feedback: to provide constructive feedback on ACP
  * #acp-service-status: provides the current status of ACP services (also available on [ACP Status][acp_status])
  * #acp-support: to raise specific and/or urgent queries with the ACP Support team
  * #community: to communicate with other ACP users

## Install binaries

To deploy applications on ACP, you require the following binaries:

  * Git
  * Docker
  * Drone CLI
  * kubectl
  * AWS CLI

The following sections provide information on how to install and verify these binaries on your system.

### Install Git

To check if Git is already installed on your system, run the following command:

```
$ git --version
```

If Git is installed, the command returns the build version your system is running, for example:

```
git version 2.16.2
```

If Git is not installed, see the [Git documentation][git_docs] for instructions. After the download completes, run the `git --version` command again to ensure Git successfully installed on your system.

### Install Docker

See the [Docker documentation][docker_docs] for instructions on how to download and install Docker. After the installation completes, verify it was successful:

```
$ docker --version
```

If the installation was successful, the command returns the version of Docker your system is running, for example:

```
Docker version 18.03.1-ce, build 9ee9f40# version 17.06 or above is required
```

### Install Drone

Our Drone server instance is currently compatible with version 1.2.2, which is available [here][drone_1.2]. See the [Drone website][drone_docs] for instructions on how to download and install Drone CLI; ensure you modify the command to install the correct version.

Verify the installation was successful:

```
$ drone --version
```

If the installation was successful, the command returns the version of Drone your system is running, for example:

```
drone version 1.2.2
```

### Install kubectl

See the [Kubernetes documentation][kube_docs] for instructions on how to download and install kubectl. Ensure the version you install is within one minor version of ACP; you can check which version ACP is running [here][kube_version].

Verify the installation was successful:

```
$ kubectl version --client  
```

Successful installations return the build version, for example:

```
Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.4", GitCommit:"c27b913fddd1a6c480c229191a087698aa92f0b1", GitTreeState:"clean", BuildDate:"2019-02-28T13:37:52Z", GoVersion:"go1.11.5", Compiler:"gc", Platform:"linux/amd64"}
```

### Install AWS CLI

The ACP Induction requires version 1.11.91 or above of AWS CLI. See the [AWS documentation][aws_docs] for download and installation instructions.

Verify the installation was successful:

```
$ aws --version
```

Successful installations return the build version your system is running.

### Connect to the cluster

In order to access a namespace, you need to configure kubectl to connect to ACP’s clusters. Select **Set up Kube Config** on the
[Connected Identities][connected_ids] page of ACP Hub for instructions.

To verify that your kubectl is configured properly, try to list pods in the `acp-induction` namespace:

```
$ kubectl --context=acp-notprod_acp-induction --namespace=acp-induction get pods
No resources found
```

In this example, there are no pods yet in the `acp-induction` namespace. Next, check if there are any secrets:

```
$ kubectl --context=acp-notprod_acp-induction --namespace=acp-induction get secrets
NAME                  TYPE                                  DATA      AGE
default-token-dcnmg   kubernetes.io/service-account-token   3         105d
```

A service account token is assigned to the namespace.

## User agreement

Finally, read the [ACP support documentation][support_docs] to familiarise yourself with the level of service ACP provides, including the level and hours of support on offer and issue escalation procedures.

[induction_signup]: https://www.eventbrite.co.uk/e/application-container-platform-induction-tickets-43478619722
[induction_material]: https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/94
[windows_subsystem]: https://docs.microsoft.com/en-us/windows/wsl/about
[govwifi]: https://www.wifi.service.gov.uk/about-govwifi/connect-to-govwifi/
[openvpn]: https://openvpn.net/community-downloads/
[remote_access]: https://access-acp.digital.homeoffice.gov.uk/ui/profiles
[acp_hub]: https://hub.acp.homeoffice.gov.uk/
[acp_support]: https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1
[email_update]: https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/98
[connected_ids]: https://hub.acp.homeoffice.gov.uk/identities
[git_basics]: https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository
[gitlab_docs]: https://docs.gitlab.com/ee/ssh/
[acp_sysdig]: https://sysdig.digital.homeoffice.gov.uk/
[acp_slack]: https://hod-dsp.slack.com/signup#/
[acp_status]: https://status.acp.homeoffice.gov.uk/
[git_docs]: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
[docker_docs]: https://docs.docker.com/engine/install/
[drone_docs]:https://docs.drone.io/cli/install/
[drone_1.2]: https://github.com/drone/drone-cli/releases/tag/v1.2.2
[kube_docs]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[kube_version]: https://gitlab.digital.homeoffice.gov.uk/acp-docs/acp-support/blob/master/release-notes/kubernetes.md
[aws_docs]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
[connected_ids]: https://hub.acp.homeoffice.gov.uk/identities
[support_docs]: https://gitlab.digital.homeoffice.gov.uk/acp-docs/acp-support
