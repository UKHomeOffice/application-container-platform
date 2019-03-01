## Using artifactory as a private npm registry

[TOC]

A step-by-step guide.

This guide makes the following assumptions:

* you have drone ci set up for your project already
* you are using `node@8` and `npm@5` or later
* you are connected to ACP VPN

#### Setting up a local environment

##### Get your username and API key from artifactory

Visit https://artifactory.digital.homeoffice.gov.uk/artifactory/webapp/#/profile, make a note of your username, and if you don't already have an API key then generate one.

##### base64 encode your API key

```
echo -n <api key> | base64
```

##### Set local environment variables

Copy your encoded password, and set the following environment variables in your bash profile:

```
export NPM_AUTH_USERNAME=<username>
export NPM_AUTH_TOKEN=<base64 encoded api key>
```

You might then need to `source` your profile to load these environment variables.

#### Setting up CI in drone

##### Request a bot token for artifactory

You can do this through the [ACP Hub](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/artifactory-bot). You'll need to provide a username for the bot when you create it.

One of the ACP team will create a token and send it to you as an encrypted gpg file via email.

Decrypt the token

```
gpg --decrypt ./path/to/file.gpg
```

##### Add the token to drone as a secret

First, base64 encode the token:

```
echo -n "<token>" | base64
```

Then add this token to drone as a secret:

```
drone secret add UKHomeOffice/<repo> NPM_AUTH_TOKEN <base64-encoded-token> --event pull_request
```

**Note: You will need to make sure the event types are lowercase. If an event is capitalised, it won't match the standard events inside of drone**

Note: you will need to make the secret available to pull request builds to be able to run npm commands in pull request steps

##### Expose secret to build steps

You will need to configure any steps which use npm to be able to access the secret. Do this by adding a `secret` property to those steps as follows:

```yaml
  my_step:
    image: node:8
    secrets:
      - npm_auth_token
    commands:
      - npm install
      - npm test
```

##### Expose username to build steps

In addition, you will need to add the username (as you provided when creating your token) as an environment variable. The easiest way to do this is as a "matrix" variable, which makes the username available to all steps without needing to configure them all individually.

```yaml
matrix:
  NPM_AUTH_USERNAME:
    - <username>
```

#### Publishing modules to artifactory

It is generally recommended to use a common namespace to publish your modules under. npm allows namespace specific configuration, which makes it easier to ensure that modules are always installed from artifactory, and will not accidentally try to install a public module with the same name.

##### Setting publish registry

Add `publishConfig` to package.json. This ensures that the module can only ever be published to the private registry, and misconfiguration won't accidentally make it public

```json
"publishConfig": {
  "registry": "https://artifactory.digital.homeoffice.gov.uk/artifactory/api/npm/npm-virtual/"
}
```

##### Add auth settings

In your project's `.npmrc` file (create one if it does not already exist) add the following lines:

```
//artifactory.digital.homeoffice.gov.uk/artifactory/api/npm/npm-virtual/:username=${NPM_AUTH_USERNAME}
//artifactory.digital.homeoffice.gov.uk/artifactory/api/npm/npm-virtual/:_password=${NPM_AUTH_TOKEN}
//artifactory.digital.homeoffice.gov.uk/artifactory/api/npm/npm-virtual/:email=test@example.com
```

The email address can be anything, it just needs to be set.

##### Add publish step to drone

Add the following step to your `.drone.yml` file to publish a new version whenever you release a tag.

```yaml
  publish:
    image: node:8
    secrets:
      - npm_auth_token
    commands:
      - npm publish
    when:
      event: tag
```

Now, when you push new tags to github then drone should publish them to the artifactory npm registry automatically.

#### Using modules from artifactory as dependencies

##### Configure your project to use artifactory

In the project which is has private modules as dependencies, add the following line to `.npmrc` in the root of the project (create this file if it does not exist).

```
@<namespace>:registry = https://artifactory.digital.homeoffice.gov.uk/artifactory/api/npm/npm-virtual/
```

This will ensure that any module under that namespace will only ever install from artifactory, and never from the public registry

If using multiple namespaces then add a line for each namespace.

If the modules you are installing are not namespaced in artifactory, you can add the line with the namespace removed (i.e. `registry = ...`) but this will have a negative impact on install speed.

You should then add the following line to your project's `.npmrc` if they are not already there:

```
//artifactory.digital.homeoffice.gov.uk/artifactory/api/npm/npm-virtual/:username=${NPM_AUTH_USERNAME}
//artifactory.digital.homeoffice.gov.uk/artifactory/api/npm/npm-virtual/:_password=${NPM_AUTH_TOKEN}
```

You should now be able to install modules from artifactory into your local development environment.

#### Installing dependencies in docker

If you build a docker image as part of your CI pipeline, you will need to copy the `.npmrc` file into your image before installing there.

Example `Dockerfile`:

```
FROM quay.io/ukhomeofficedigital/nodejs-base:v8

ARG NPM_AUTH_USERNAME
ARG NPM_AUTH_TOKEN

COPY .npmrc /app/.npmrc
COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json
RUN npm install --production --no-optional
COPY . /app

USER nodejs

CMD node index.js
```

When building the image, you will then need to pass the username and token variables into docker with the `--build-arg` flag.

```
docker build --build-arg NPM_AUTH_USERNAME=$${NPM_AUTH_USERNAME} --build-arg NPM_AUTH_TOKEN=$${NPM_AUTH_TOKEN} .
```
