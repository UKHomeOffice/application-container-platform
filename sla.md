# ACP Support

ACP support will typically begin when a project team has been onboarded to the Platform, and will continue throughout the lifecycle of the service, including when its Live. We cover the following areas in relation to ACP:

| Type | Description |
| :--- | :--- |
| Project onboarding | For new projects/services getting started on ACP |
| Incident management | For issues with ACP or ACP related services, see [support processes](#support-processavailability) for more information |
|  Problem management | Root causes analysis of incidents, normally tracked via changes/feature requests on our [project board](https://github.com/UKHomeOffice/application-container-platform-board)
| Change management | Updates to existing services or new services in ACP - see [announcements](#announcements) section |
| Technical advice and guidance | General guidance on how to use ACP, can be raised via slack or as a P4 issue in [Jira Service Desk][Jira Service Desk] |

## Status Page

We publish the status of each of the services offered by ACP on the [ACP Status Page][Status Page].

**Before raising tickets against any of these services, please check the status page for its status.**

## Support process/availability

ACP Support is available from 9.00-5.30 on weekdays, excluding bank holidays.

ACP 24x7 support is available for services that require it. Please contact ACP through slack for more information on this.

Support requests can be made directly within [Jira Service Desk][Jira Service Desk], users can login with Keycloak using their Office 365 credentials or POISE users.

If raising a P1 or P2 against a service with ACP, please check the [ACP Status Page][Status Page] for updates.

Although our primary form of contact will be [Jira Service Desk][Jira Service Desk], we also have a support number incase you need to get in touch for an urgent P1 issue. This will be shared with your team once your service goes into Live.

## Priority Definitions & Response Times

| Severity |P1 / Urgent|P2 / High|P3 / Normal|P4 / Low|
| :--- | :--- | :--- | :--- | :--- |
| **Description** | Production system down | Production system impaired | Non production system impaired | General request |  
|**Definition**|An issue that affects your production environments where all your users, your data integrity may be at stake, and most or all of your production web application system is unavailable.|An issue that affects major functionality of your application. In High Priority issues, data integrity of the functional parts of your site is unaffected. |An issue can include technical questions, configuration issues, and defects that affect a small number of users. Typically acceptable workarounds exist. | Non-severe issues include questions, suggestions and feedback.|  


## Submitting support tickets

Support tickets can be raised via [Jira Service Desk][Jira Service Desk].

All comments relating to a support ticket will be associated with the ticket. This ensures a complete audit trail is available for each ticket.

General questions about the hosting platform can be raised on the HOD-DSP slack under the following channels:
- #community - for issues that other users in the community can answer
- #acp-support - for issues directed at ACP Support

We will endeavour to respond to Slack queries within 8 working hours.

Current BAU support contacts:

Adam Smith, Onur Yelekci, Vincent Lam and Tasharn Brown

Current issue escalation contacts:

Rick Williams


### Access and resource requests

The ACP hosting platform provides access to a number of services that can be set up for delivery teams. These services include:

* Access to UK Home Office organisation on GitHub and Quay (public container images)
* User and robot tokens to access Kubernetes clusters (please speak to your Project Admin if you're using the UK Platform)
* Allowing access to specific VPN profiles (e.g prod)
* Creating RDS with access credentials
* Creating S3 buckets and providing access credentials
* Sysdig account setup
* Permissions to push images to Artifactory
* Access to Amazon SES, verification of domains and providing SMTP credentials
* Publishing Sender Policy Framework (SPF) records for SES
* Provisioning of SQS (Simple Queue Service) and SNS (Simple Notification Service)
* Accepting peering requests and creating routes to other AWS accounts
* Creating VPN profiles for accessing other AWS accounts
* Creating DNS entries for production services

```
"Request for ADUSER - Name (or USERS if it's a list)". Please include full name, department/team and a Home Office email address where account details can be received.
```

AD-only account requests can only be raised by someone on the agreed authority list. The current list is as follows:
Andrew Martin, David McQue, Jon Shanks, Thomas Fitzherbert, Geoff Teale, Onur Yelekci, Vincent Lam and Tasharn Brown

### Out of scope

Whilst we support the ACP services and the underlying infrastructure of where your applications are hosted, the follow are out of scope for ACP Support:

* Debugging application code
* Support for HODC O & S (currently facilitated by Fujitsu)
* Requests for creation of AWS accounts (should be sent to the DMR portal, CTI team)
* Licensed Office 365 products should be requested from your programme office. We can, however, request AD-only accounts on your behalf if you raise a ticket on the BAU board as described below:

### Enhancement requests

We encourage feedback from all service delivery teams and continue to strive to improve the hosting platform and delivery framework. Any enhancement request will be looked at by the Platform Team, and potentially added to the backlog and prioritised with other work. Please raise these as a P4 in Jira Service Desk, or start a conversation with us in the #acp-support channel in slack.


## Announcements

For changes we're making to the clusters or services we offer, announcements are made through the  [Platform Hub][Hub]. Once an announcement is made, an emails get sent to every user on the hub, messaged in slack (#acp-support and #community) and can be found directly on the [Platform Hub Announcements Page](https://hub.acp.homeoffice.gov.uk/announcements/global).


[Status Page]: https://status.acp.homeoffice.gov.uk
[Jira Service Desk]: https://support.acp.homeoffice.gov.uk
[Hub]: https://hub.acp.homeoffice.gov.uk
