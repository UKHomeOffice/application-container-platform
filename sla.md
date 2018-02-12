# ACP Delivery Support Service

ACP delivery support will typically begin when a service delivery team has been on-boarded, and will continue until the service is transitioned to Live Services.

## Submitting support tickets/queries

Support tickets can be raised on the (BAU board)[https://github.com/UKHomeOffice/hosting-platform-bau/projects/1] or if your project's hosted in the UK, on the (Platform Hub)[https://hub.acp.homeoffice.gov.uk/] 

All comments relating to a support ticket will be associated with the ticket. This ensures a complete audit trail is available for each ticket.

Guidance on completing support tickets can be found on the (BAU Board)https://github.com/UKHomeOffice/hosting-platform-bau and the (Platform Hub)[https://hub.acp.homeoffice.gov.uk/help/support/requests/overview]

General questions about the hosting platform can be raised on the _HOD-DSP - General_ Slack channel.

We will endeavour to respond to a support ticket or slack query within 8 working hours of the ticket being raised.

Current BAU support contacts:

Ben Eustace, Onur Yelekci, Vincent Lam and Tasharn Brown

Current issue escalation contacts:

Rick Williams

## Support hours

Delivery support is available from 9.00-5.30 on weekdays, excluding bank holidays

## Support Scope

Delivery support will cover the following:

### Access and resource requests 

The ACP hosting platform provides access to a number of services that can be set up for delivery teams. These services include:

* Access to UK Home Office organisation on Github and Quay (public container images)
* User and robot tokens to access Kubernetes clusters (please speak to your Project Admin if you're using the UK Platform)
* Allowing access to specific VPN profiles (e.g prod)
* Creating RDS with access credentials
* Creating S3 buckets and providing access credentials
* Sysdig account setup
* Permissions to push images to Artifactory
* Access to Amazon SES, verification of domains and providing SMTP credentials
* Publishing Sender Policy Framework (SPF) records for SES
* Provisioning of SQS (Simple queuing Service) and access credentials
* Accepting peering requests and creating routes to other AWS accounts
* Creating VPN profiles for accessing other AWS accounts
* Creating DNS entries for production services

### General issue resolution

General issues can be raised on the BAU board under the _Issues_ column. All comments will be recorded against each issue, ensuring there is a well-defined narrative and history for each until they're closed. All general issues will be picked up as soon as an engineer is available. Specific project requests can also be raised on the BAU board and will be handled in the same way as issues.

### Enhancement requests

We encourage feedback from all service delivery teams and continue to strive to improve the hosting platform and delivery framework. Any enhancement request will be looked at by the Platform Team, and potentially added to the central team backlog and prioritised with other work.

## Out of scope

* Debugging application code
* Requests for creation of AWS accounts (should be sent to the DMR portal, CTI team)
* Licensed Office 365 products should be requested from your programme office. 

We can, however, request AD-only accounts on your behalf if you raise a ticket on the BAU board as described below:

Title: "Request for ADUSER - Name (or USERS if it's a list)". Please include full name, department/team and a Home Office email address where account details can be received.

AD-only account requests can only be raised by someone on the agreed authority list. The current list is as follows:
Andrew Martin, David McQue, Ben Eustace, Jon Shanks, Thomas Fitzherbert, Geoff Teale, Onur Yelekci, Vincent Lam and Tasharn Brown
