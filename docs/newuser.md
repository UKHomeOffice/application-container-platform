# Flow for new users
This document will go over the flow for getting access to our various services

## Publicly Accessible
These are all services that you can access through normal internet access with personal accounts.
### GitHub
[Github](https://github.com/UKHomeOffice) to access our repositories you must have your personal Github invited to the UK Home Office organisation on Github, someone with access can request this for you.
### Quay
[Quay](https://quay.io) You can access this with your github account after requesting access to our Quay Organisation with your personal account. Requests should be raised on the [bau board](https://github.com/UKHomeOffice/application-container-platform-bau/issues)

## Office 365 Account
[Office 365](https://portal.office.com) If you are part of digital you should be provided with one of these. If not you can raise a ticket on the [bau board](https://github.com/UKHomeOffice/application-container-platform-bau/issues) and you will be provided with an AD only account to use.

### Artifactory
[Artifactory](https://artifactory.digital.homeoffice.gov.uk.). Sign in with office 365 button. The docker repository in artifactory is accessed by the docker.digital.homeoffice.gov.uk address.
### Gitlab
[GitLab](https://gitlab.digital.homeoffice.gov.uk) To get access to this you will need to first login via office 365 by clicking the office 365 login button and and then request for your account to be unblocked.
## VPN
The VPN is used to be able to get through to our multiple AWS environments as well as other data centers. The profiles can be downloaded from [authd](https://authd.digital.homeoffice.gov.uk) which you can access using your office 365 SSO. The following services can be only accessed when connected to the Dev VPN profile.
### Kubernetes
You will need a token before you can access any of the clusters. These can be requested on the [bau board](https://github.com/UKHomeOffice/application-container-platform-bau/issues).
### Drone
We have two instances [gitlab](https://drone-gitlab.digital.homeoffice.gov.uk) uses your gitlab login and the one for [github](https://drone.digital.homeoffice.gov.uk) uses your github login.
### Kibana
[Kibana](https://kibana.ops.digital.homeoffice.gov.uk) uses office365 sigin.
### Sysdig
[Sysdig](https://sysdig.digital.homeoffice.gov.uk). You need to request an account on our [bau board](https://github.com/UKHomeOffice/application-container-platform-bau/issues) if you want access.
## AWS
Access to AWS is managed by the [Hoddat-iam](https://gitlab.digital.homeoffice.gov.uk/Devops/hoddat-iam) repo.
