## Getting a Kubernetes Robot Token

#### Users

1. Log into the [Platform Hub][platform hub link].

2. Go to the [Projects][project list] section and find your project. Click on the **Services** tab and find the service that requires a robot token.

3. Go to the **Kube Robot Tokens** tab. Any robot tokens that have been created for that service will be listed. You can see the full token by clicking on the eye icon next to the token.

If there are no robot tokens for that service, or the required one is not there, you will need to ask your project admin(s) to create a robot token.

#### Project Admins (Creating a robot token)

1. Log into the [Platform Hub][platform hub link].

2. Go to the [Projects][project list] section and find your project. Click on the **Services** tab and find the service that requires a robot token.

3. Go to the **Kube Robot Tokens** tab and click the **Create a Kubernetes robot token for this service** button.

4. Select the required cluster, RBAC group(s), robot name and description for the robot token and click **Create**.

> An explanation of RBAC groups can be found here: [RBAC Groups][rbac groups]

5. Users who are part of the project will be able to view the token in the same place you created it (Project -> Service -> Kube Robot Tokens).


[platform hub link]: https://hub.acp.homeoffice.gov.uk/
[project list]: https://hub.acp.homeoffice.gov.uk/projects/list
[rbac groups]: https://github.com/UKHomeOffice/application-container-platform/blob/master/docs/rbac.md
