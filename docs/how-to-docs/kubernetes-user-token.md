## Getting a Kubernetes Token

#### Users

1. Log into the [Platform Hub][platform hub link].

2. Go to the [Projects][project list] section and find your project. On the **Overview & People** tab, you should see a list of team members and the project admin (who will have the admin tag next to their name).

3. Talk to your project admin and ask them to generate a user token for you.

4. Once your token has been created, you will be able to find it in the [Connected Identities][connected identities] section. You will need to expand the **Kubernetes** identity and show your full token by clicking the eye icon next to it.

#### Project Admins (Creating a user token)

1. Log into the [Platform Hub][platform hub link].

2. Go to the [Projects][project list] section and find your project. Click on the **Kube User Tokens** tab, click **Select a project team member** and select the requesters name from the list.

3. Click **CREATE A NEW KUBERNETES USER TOKEN FOR THIS USER**.

4. Select the required cluster and RBAC group(s) needed for the token and click **Create**.

> An explanation of RBAC groups can be found here: [RBAC Groups][rbac groups]

5. Once the token is created the requester should be able to see it in their **Connected Identities** section for use in their Kube config.

**Note:** Tokens can take a while to propagate so you may have to wait for up to 10 minutes before using a new token.

[platform hub link]: https://hub.acp.homeoffice.gov.uk
[connected identities]: https://hub.acp.homeoffice.gov.uk/identities
[project list]: https://hub.acp.homeoffice.gov.uk/projects/list
[rbac groups]: https://github.com/UKHomeOffice/application-container-platform/blob/master/docs/rbac.md
