# Flow for new users
This document will go over the flow for getting access to our various services if you are finding difficulties with the specifics of the tasks outlined in this document please see the more detailed [Developer Docs]()

## Office 365 Account
[Office 365](https://portal.office.com), these are provided by the Office 365, Single Sign On (SSO) is managed as part of an on-boarding process, which will be managed by your project manager / delivery manager to the Office 365 team. This is not managed by us. Please note that for SSO which is using your Office 365 account to log onto other services pop-ups will need to be enabled on your computer.

## VPN
The VPN is used to be able to get through to our multiple AWS environments as well as other data centers. The profiles can be downloaded from [access](https://access-acp.digital.homeoffice.gov.uk) which you can access using your Office 365 SSO. The following services can be only accessed when connected to the Dev VPN profile.

## Platform Hub 
[The Platform Hub](https://hub.acp.homeoffice.gov.uk) serves as a central portal for users of ACP. It acts as an all-in-one place to find information, requests and also support for the platform. The hub also provides tools to develop, build, deploy and manage all your projects.

## Externally Accessible (for open source projects)
These are all services that you can access through normal internet access with personal accounts.
### GitHub
[Github](https://github.com/UKHomeOffice) to access our repositories you must have your personal Github invited to the UK Home Office organisation on Github. This is done during your first login to the Platform Hub. Please note that you will have to have your full name as your name on github along with 2 Factor Authentication. If you don't have a personal account on Github then you will need to create one.

### Quay
[Quay](https://quay.io) You can access this with your GitHub account after requesting access to our Quay Organisation with your personal account. Requests can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/quay-robot-request)

## Internally Accessible

### Artifactory
[Artifactory](https://artifactory.digital.homeoffice.gov.uk.). Requests can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/artifactory-bot) Sign in with Office 365 button. The docker repository in artifactory is accessed by the docker.digital.homeoffice.gov.uk address.

### Gitlab
[GitLab](https://gitlab.digital.homeoffice.gov.uk) To get access to this you will need to first login via Office 365 by clicking the Office 365 login button.

### Kubernetes
You will need a token before you can access any of the clusters. Requests can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/kubernetes-token) 

### Drone
We have two instances [gitlab](https://drone-gitlab.digital.homeoffice.gov.uk) uses your GitLab login and the one for [github](https://drone.digital.homeoffice.gov.uk) uses your github login.

### Kibana
[Kibana](https://kibana.ops.digital.homeoffice.gov.uk). To use Kibana you will need an account to be setup. Requests can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/kibana-auth)

### Sysdig
[Sysdig](https://sysdig.digital.homeoffice.gov.uk). Requests can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/sysdig-account) 

## AWS
Please use the request form on the Platform Hub to ask the ACP team to grant access. Requests can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/aws-service)
