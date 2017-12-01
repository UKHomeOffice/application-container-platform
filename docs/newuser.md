# Flow for new users
This document will go over the flow for getting access to our various services if you are finding difficulties with the specifics of the tasks outlined in this document please see the more detailed [Developer Docs][developer docs link].

## Office 365 Account
[Office 365](https://portal.office.com) accounts are provided by the Office 365 team, Single Sign On (SSO) is managed as part of an on-boarding process, which will be managed by your project manager / delivery manager to the Office 365 team. This is not managed by us. Please note that to use SSO, which is using your Office 365 account to log onto other services, pop-ups will need to be enabled on your computer.

## VPN
VPN profiles are used to be able to get through to our multiple AWS environments as well as other data centers. The profiles can be downloaded from [access](https://access-acp.digital.homeoffice.gov.uk) which you can access using your Office 365 SSO. The following services can be only accessed when connected to the Dev VPN profile.

## Platform Hub 
[The Platform Hub](https://hub.acp.homeoffice.gov.uk) serves as a central portal for users of ACP. It acts as an all-in-one place to find information, requests and also support for the platform. The hub also provides tools to develop, build, deploy and manage all your projects.

## Externally Accessible (for open source projects)
These are all services that you can access through normal internet access with personal accounts.
### GitHub
[Github](https://github.com/UKHomeOffice) - To access our repositories you must have your personal Github invited to the UK Home Office organisation on Github. This is done during your first login to the Platform Hub. Please note that you will have to have your full name as your name on github along with 2 Factor Authentication. If you don't have a personal account on Github then you will need to create one.

### Quay
[Quay](https://quay.io) - You can access Quay using your GitHub account. Once you have been added to the ukhomeoffice organisation on Quay, you can create repositories in the organisation. If you are not already part of the organisation you can submit a [support request on the Platform Hub to be added][quay add to org support request]. You will also need a robot created for you to push to your repository once you have created one. Requests for a Quay robot can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/quay-robot-request).

## Internally Accessible

### Artifactory
[Artifactory](https://artifactory.digital.homeoffice.gov.uk.) - Once you have an Office 365 account, you can sign in using the HOD SSO button. Requests for an Artifactory robot can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/artifactory-bot). The docker repository in Artifactory is accessed via the `docker.digital.homeoffice.gov.uk` address.

### GitLab
[GitLab](https://gitlab.digital.homeoffice.gov.uk) - Once you have an Office 365 account, you can sign in using the Office 365 button.

### Kubernetes
You will need a Kubernetes user token before you can access any of the namespaces in the clusters. Follow the instructions here to get one for your teams namespaces: [Getting a Kubernetes Token for the UK cluster][kube user token doc]

### Drone
We have two instances; One for [GitHub](https://drone.acp.homeoffice.gov.uk) and one for [GitLab](https://drone-gitlab.acp.homeoffice.gov.uk).

### Kibana
[Kibana](https://kibana.acp.homeoffice.gov.uk) - To use Kibana you will need an account to be setup. Requests for this can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/kibana-auth).

### Sysdig
[Sysdig](https://sysdig.digital.homeoffice.gov.uk) - Requests for Sysdig accounts can be made on the [Platform Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/sysdig-account). 

## AWS Resources (S3 Buckets and RDS Instances)
If you require an S3 bucket or an RDS instance you can submit a support request for either on the Platform Hub. Instructions can be found here: [Getting Amazon resources][amazon resources doc]

[developer docs link]: https://github.com/UKHomeOffice/application-container-platform/blob/master/developer-docs/README.md
[quay add to org support request]: https://hub.acp.homeoffice.gov.uk/help/support/requests/new/quay-add-to-org
[kube user token doc]: https://github.com/UKHomeOffice/application-container-platform/blob/master/how-to-docs/kubernetes-user-token.md
[amazon resources doc]: https://github.com/UKHomeOffice/application-container-platform/blob/master/how-to-docs/amazon-resources.md
