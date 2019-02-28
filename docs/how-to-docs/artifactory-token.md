
# Create an Artifactory access token

> Note: These instructions are intended for the ACP team. If you would like to request an Artifactory token, please use the relevant support request on the [Platform Hub][artifactory support request].

The requester should state the name of the token, how they would like to receive the token and post their GPG key.

* Create an [Artifactory][artifactory link] access token using the following command:
```
curl -u<username>:<api-key> -XPOST "https://artifactory.digital.homeoffice.gov.uk/artifactory/api/security/token" -d "username=<robot-username>" -d "scope=member-of-groups:<appropriate-groups>" -d "expires_in=0"
```

where `<robot-username>` is the name of the access token and `<appropriate-groups>` is a comma separated list of the groups the token should be in (normally this will only be `ci`).

> Note: If you set the `expires_in` time higher than 0, you will not be able to revoke the token via the UI.

* Once the token has been created, JSON data should be returned which will include the access key. The JSON data you receive will be the only time you will be able to see the access key as it is not shown on Artifactory. You should, however, be able to see the name and expiry date (if you set an expiry time) of the access key in the "Access Keys" section.

[artifactory support request]: https://hub.acp.homeoffice.gov.uk/help/support/requests/new/artifactory-token
[artifactory link]: https://artifactory.digital.homeoffice.gov.uk/
