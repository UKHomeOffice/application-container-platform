# ACP Delivery Support Service

ACP delivery support will typically begin when a service delivery team has been on-boarded, and will continue until the service is transitioned to Live Services.

## Submitting support tickets/queries

Support tickets can be raised on the BAU board here:

 https://github.com/UKHomeOffice/hosting-platform-bau/projects/1

All comments relating to a support ticket will be associated with the ticket. This ensures a complete audit trail is available for each ticket.

Guidance on completing support tickets can be found here:

https://github.com/UKHomeOffice/hosting-platform-bau

General questions about the hosting platform can be raised on the _HOD-DSP - General_ slack channel.

We will endeavour to respond to a support ticket or slack query within 8 working hours of the ticket being raised. 

Current BAU support contacts:

Joseph Irving: joseph.irving@digital.homeoffice.gov.uk

Current issue escalation contacts:

Rick Williams: rick.williams@digital.homeoffice.gov.uk

## Support hours

Delivery support is available from 9.00-5.30 on weekdays, excluding Bank holidays 

## Support Scope

Delivery support will cover the following:

### Access requests to ACP services

The ACP hosting platform provides access to a number of services that can be set up for delivery teams. These services include:

* Access to HOD-DSP slack channel for support queries
* Access to UK home office Github organisation
* Un-blocking Gitlab accounts. Note: a Gitlab account is created automatically with O365, but blocked by default.
* Tokens to access Kubernetes
* Allowing access to specific VPN profiles (eg prod)
* Sysdig account setup
* Permissions to push images to Artifactory
* Access to the UK Home Office Quay organisation (public docker containers)

To request access to any of the above services, please raise a ticket on the BAU board.

### Access requests to Amazon services

* Access to Amazon SES
* Providing SMTP credentials
* Verifying domains and email addresses when using the Amazon Simple Email Service (SeS) 
* Publishing Sender Policy Framework (SPF) records for SES 
* Creating RDS with access credentials
* Creating S3 buckets and providing  access credentials
* Provisioning of SQS (Simple queuing Service) and access credentials
* Accepting peering requests and creating routes to other AWS accounts
* Create VPN profiles for accessing other AWS accounts 

To request access to any of the above services, please raise a ticket on the BAU board

### DNS setup

* Creating dns entries for production services 

To request the creation of a dns entry, please raise a ticket on the BAU board.

### General Issue resolution

General issues can be raised on the BAU board under the _Issues_ column. All comments will be recorded against each issue, ensuring there is a well-defined narrative & history for each issue until the issue is closed.
All general issues will be picked up as soon as an engineer is available.

### Specific project requests

Specific project requests can also be raised on the BAU board and will be handled in the same way as issues. 

### Enhancement requests

We encourage feedback from all service delivery teams and continue to strive to improve the hosting platform and delivery framework. Any  enhancement request will be looked at by the Central team, and potentially added to the central team backlog and prioritised with other work.

## Out of scope

* Office 365 account setup. This can be requested through the following process:

Email sent to the hodo365team@digital.homeoffice.gov.uk titled "Request for ADUSER - Name (or just USERS if its a list)"

Email needs to be FROM someone on the agreed authority list. The current list is as follows: 

Andrew Martin - andrew.martin16@homeoffice.gsi.gov.uk

David McQue - David.McQue@homeoffice.gsi.gov.uk

Joseph Irving - Joseph.Irving@digital.homeoffice.gov.uk

Jon Shanks - Jon.shanks@digital.homeoffice.gov.uk

Thomas Fitzherbert - thomas.fitzherbert1@homeoffice.gsi.gov.uk

Geoff Teale - Geoff.Teale@homeoffice.gsi.gov.uk

Email contents:

1. Name (as in Firstname and lastname); 
2. POISE email (that the script sends the welcome email and creds to) if not available then we can send it to the requestors email;
3. Department (as in DSAB, AFTC etc)

* Debugging application code
* Requests for creation of AWS accounts should be sent to the DMR portal (CTI team)
