# Create an Artifactory access token

> Note: These instructions are intended for the ACP team. If you would like to request an Artifactory token, please use the relevant support request on the [Platform Hub][artifactory support request].

The requester should state the name of the token, how they would like to receive the token and post their GPG key.

* Create an [Artifactory][artifactory link] access token using the following command:
```
curl -u<username>:<api-key> -XPOST "https://artifactory.digital.homeoffice.gov.uk/artifactory/api/security/token" -d "username=<robot-username>" -d "scope=member-of-groups:<appropriate-groups>" -d "expires_in=9999999999"
```

where `<robot-username>` is the name of the access token and `<appropriate-groups>` is a comma seperated list of the groups the token should be in (normally this will only be `ci`).

* Once the token has been created, JSON data should be returned which will include the access key. The JSON data you recieve will be the only time you will be able to see the access key as it is not shown on Artifactory. You should, however, be able to see the name and expiry date of the access key in the "Access Keys" section.

[artifactory support request]: https://hub.acp.homeoffice.gov.uk/help/support/requests/new/artifactory-bot
[artifactory link]: https://artifactory.digital.homeoffice.gov.uk/
