## Drone How To

#### Install Drone CLI

- Github drone instance: https://drone.acp.homeoffice.gov.uk/
- Gitlab drone instance: https://drone-gitlab.acp.homeoffice.gov.uk/

Download and install the [Drone CLI][drone docs - cli install].

> At the time of writing, we are using version 0.8 of Drone.

You can also install a release from [Drone CLI's GitHub repo][drone cli releases].
Once you have downloaded the relevant file, extract it and move it to the `/usr/local/bin` directory.


Verify it works as expected:

```bash
$ drone --version
drone version 0.8.0
```

Export the `DRONE_SERVER` and `DRONE_TOKEN` variables. You can find your token on Drone by clicking the icon in the top right corner and going to [Token][drone github token page].

```bash
export DRONE_SERVER=https://drone.acp.homeoffice.gov.uk
export DRONE_TOKEN=<your_drone_token>
```

If your installation is successful, you should be able to query the current Drone instance:

```bash
$ drone info
User: youruser
Email: youremail@gmail.com
```

> If the output is
>
> ```bash
> Error: you must provide the Drone server address.
> ```
>
> or
>
> ```
> Error: you must provide your Drone access token.
> ```
>
>  Please make sure that you have exported the `DRONE_SERVER` and `DRONE_TOKEN` variables properly.

#### Activate your pipeline

Once you are logged in to Drone, you will find a list of repos by clicking the icon in the top right corner and going to [Repositories][drone github repos page].

Select the repo you want to activate.

Navigate to your repository's settings in Github (or Gitlab) and you will see a webhook has been created. You need to update the url for the newly created web hook so that it matches this pattern:

```
https://drone-external.acp.homeoffice.gov.uk/hook?access_token=some_token
```

> If it is already in that format there is no need to change anything.
>
> The token in the payload url will not be the same as the personal token that you exported and it should be left unchanged.
>
> **Please note that this does not apply to Gitlab. When you activate the repo in Drone, you should not change anything for a Gitlab repo.**

#### Configure your pipeline

In the root folder of your project, create a `.drone.yml` file with the following content:

```yaml
pipeline:

  my-build:
    image: docker:18.03
    environment:
      - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
      - docker build -t <image_name> .
    when:
      branch: master
      event: push
```

Commit and push your changes:

```bash
$ git add .drone.yml
$ git commit
$ git push origin master
```

> **Please note** you should replace the name <...> with the name of your app.

You should be able to watch your build succeed in the Drone UI.

#### Publishing Docker images

##### Publishing to Quay

If your repository is hosted on Gitlab, you don't want to publish your images to Quay. Images published to Quay are public and can be inspected and downloaded by anyone. [You should publish your private images to Artifactory](#publishing-to-artifactory).

Register for a free [Quay account][quay link] using your Github account linked to the Home Office organisation.

Once you've logged into Quay check that you have `ukhomeofficedigital` under Users and Organisations.
If you do not, [submit a support request on the platform hub for access to the ukhomeoffice organisation][add to quay support request].

Once you have access to view the `ukhomeofficedigital` repositories, click repositories and
click the `+ Create New Repositories` that is:

- public
- empty - no need to create a repo from a Dockerfile or link it to an existing repository

Add your project to the UKHomeOffice Quay account and [submit a support request on the platform hub for a new Quay robot][quay robot support request].

Add the step to publish the docker image to Quay in your Drone pipeline:

```yaml
image_to_quay:
  image: quay.io/ukhomeofficedigital/drone-docker
  secrets:
    - docker_password
  environment:
    - DOCKER_USERNAME=ukhomeofficedigital+<your_robot_username>
  registry: quay.io
  repo: quay.io/ukhomeofficedigital/<your_quay_repo>
  tags:
    - ${DRONE_COMMIT_SHA}
    - latest
  when:
    branch: master
    event: push
```

Where `<your_quay_repo>` in:

```yaml
quay.io/ukhomeofficedigital/<your_quay_repo>
```

is the name of the Quay repo you (should) have already created.

> Note: ${DRONE_COMMIT_SHA} is a Drone environment variable that is passed to the container at runtime.

The build should fail with the following error:

```bash
Error response from daemon: Get https://quay.io/v2/: unauthorized: Could not find robot with username: ukhomeofficedigital+<your_robot_username> and supplied password.
```

The error points to the missing password for the Quay robot. You will need to add this as a drone secret.

You can do this through the Drone UI by going to your repo, clicking the menu icon in the top right and then clicking **Secrets**. You should be presented with a list of the secrets for that repo (if there are any) and you should be able to add secrets giving them a name and value. Add a secret with the name `DOCKER_PASSWORD` and with the value being the robot token that was supplied to you.

Alternatively, you can use the Drone CLI to add the secret:

```
$ drone secret add --repository ukhomeoffice/<your_github_repo> --name DOCKER_PASSWORD --value <your_robot_token>
```

Restarting the build should be enough to make it pass.

> The Drone CLI allows for more control over the secret as opposed to the UI. For example, the CLI allows you to specify the image and the events that the secret will be allowed to be used with.
>
> Also note that the secret was specified in the `secrets` section of the pipeline to give it access to the secret. Without this, the pipeline would not be able to use the secret and it would fail. Secrets in this section are automatically uppercased at runtime so it is important that the secret is uppercased in your commands.

You can also push specifically tagged images by using the `DRONE_TAG` Drone environment variable and by using the `tag` event:

```yaml
tagged_image_to_quay:
  image: quay.io/ukhomeofficedigital/drone-docker
  secrets:
    - docker_password
  environment:
    - DOCKER_USERNAME=ukhomeofficedigital+<your_robot_username>
  registry: quay.io
  repo: quay.io/ukhomeofficedigital/<your_quay_repo>
  tags:
    - ${DRONE_TAG}
  when:
    event: tag
```

Tag using `git tag v1.0` and push your tag with `git push origin v1.0` (replace `v1.0` with the tag you actually want to use).

> Note: These pipeline configurations are using the Docker plugin for Drone. For more information, see http://plugins.drone.io/drone-plugins/drone-docker/

##### Publishing to Artifactory

Images hosted on [Artifactory][artifactory link] are private.

If your repository is hosted publicly on GitHub, you shouldn't publish your images to Artifactory. Artifactory is only used to publish private images. [You should use Quay to publish your public images](#publishing-to-quay).

[Submit a support request for a new Artifactory access token][artifactory support request]. You should be supplied an access token in response.

You can inject the token that has been supplied to you with:

```
$ drone secret add --repository <gitlab_repo_group>/<your_gitlab_repo> --name DOCKER_PASSWORD --value <your_robot_token>
```

You can add the following step in your `.drone.yml`:

```yaml
image_to_artifactory:
  image: quay.io/ukhomeofficedigital/drone-docker
  secrets:
    - docker_password
  environment:
    - DOCKER_USERNAME=<your_robots_username>
  registry: docker.digital.homeoffice.gov.uk
  repo: docker.digital.homeoffice.gov.uk/<your_artifactory_repo>
  tags:
    - ${DRONE_COMMIT_SHA}
    - latest
  when:
    branch: master
    event: push
```

Where the `<image_name>` in:

```yaml
docker tag <image_name> docker.digital.homeoffice.gov.uk/ukhomeofficedigital/<your_artifactory_repo>:$${DRONE_COMMIT_SHA}
```

is the name of the image you tagged previously in the build step.

The image should now be published on Artifactory.

#### Deployments

##### Deployments and promotions

Create a step that runs only on deployments:

```yaml
deploy-to-preprod:
  image: busybox
  commands:
    - /bin/echo hello preprod
  when:
    environment: preprod
    event: deployment
```

Push the changes to your remote repository.

You can deploy the build you just pushed with the following command:

```bash
$ drone deploy ukhomeoffice/<your_repo> 16 preprod
```

Where `16` is the successful build number on drone that you wish to deploy to the `preprod` environment.

You can pass additional parameters to your deployment as environment variables:

```bash
$ drone deploy ukhomeoffice/<your_repo> 16 preprod -p DEBUG=1 -p NAME=Dan
```

and use them in the step like this:

```yaml
deploy-to-preprod:
  image: busybox
  commands:
    - /bin/echo hello $${NAME}
  when:
    environment: preprod
    event: deployment
```

Environments are strings and can be set to any value. When you wish to deploy to several environments you can create a step for each one of them:

```yaml
deploy-to-preprod:
  image: busybox
  commands:
    - /bin/echo hello preprod
  when:
    environment: preprod
    event: deployment

deploy-to-prod:
  image: busybox
  commands:
    - /bin/echo hello prod
  when:
    environment: prod
    event: deployment
```

And deploy them accordingly:

```bash
$ drone deploy ukhomeoffice/<your_repo> 16 preprod
$ drone deploy ukhomeoffice/<your_repo> 16 prod
```

Read more on [environments][drone docs - environments].

##### Drone as a Pull Request builder

Drone pipelines are triggered when events occurs. Event triggers can be as simple as a _push_, _a tagged commit_, _a pull request_ or as granular as _only for pull requests for a branch named `test`_. You can limit the execution of build steps at runtime using the `when` block. As an example, this block executes only on pull requests:

```yaml
pr-builder:
  image: docker:18.03
  environment:
    - DOCKER_HOST=tcp://172.17.0.1:2375
  commands:
    - docker build -t <image_name> .
  when:
    event: pull_request
```

Drone will only execute that step when a new pull request is raised (and when pushes are made to the branch while a pull request is open).

[Read more about Drone conditions][drone docs - conditions].

##### Deploying to ACP

> Please note that this section assumes that you already have kube files to work with (specifically, deployment, service and ingress files).
> Examples of these files can be found in the [kube-signed-commit-check][kube signed commit check repo] project.

Add a deployment script with the following:

```bash
#!/bin/bash
export KUBE_NAMESPACE=<dev-induction>
export KUBE_SERVER=${KUBE_SERVER}
export KUBE_TOKEN=${KUBE_TOKEN}

kd  -f deployment.yaml \
    -f service.yaml \
    -f ingress.yaml
```

> Please note that this is only an example script and it will need to be changed to fit your particular application's needs.

If you deployed this now you would likely receive an error similar to this:

```bash
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

This error appears because [kd][kd repo] needs 3 environment variables to be set before deploying:

- `KUBE_NAMESPACE` - The kubernetes namespace you wish to deploy to. **You need to provide the kubernetes namespace as part of the deployment job**.

- `KUBE_TOKEN` - This is the token used to authenticate against the kubernetes cluster. **If you do not already have a kube token, [here are docs explaining how to get one][kube token how to]**.

- `KUBE_SERVER` - This is the address of the kubernetes cluster that you want to deploy to.

You will need to add `KUBE_TOKEN` and `KUBE_SERVER` as drone secrets. Information about how to add Drone secrets can be found in the [publishing to Quay section](#publishing-to-quay).

You can verify that the secrets for your repo are present with:

```bash
$ drone secret ls --repository ukhomeoffice/<your-repo>
```

Once the secrets have been added, add a new step to your drone pipeline that will execute the deployment script:

```yaml
deploy_to_uat:
  image: quay.io/ukhomeofficedigital/kd:v0.11.0
  secrets:
    - kube_server
    - kube_token
  commands:
    - ./deploy.sh
  when:
    environment: uat
    event: deployment
```

#### Using Another Repo

It is possible to access files or deployment scripts from another repo, there are two ways of doing this.

The recommended method is to clone another repo in the current repo (since this only requires maintaining one .drone.yml) using the following step:

```yaml
predeploy_to_uat:
  image: plugins/git
  commands:
    - git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo>.git
  when:
    environment: uat
    event: deployment
```

Your repository is saved in the workspace, which in turn is shared among all steps in the pipeline.

However, if you decide that you want to trigger a completely different pipeline on a separate repository, you can leverage the [drone-trigger][drone-trigger repo] plugin. If you have a secondary repository, you can setup Drone on that repository like so:

```yaml
pipeline:
  deploy_to_uat:
    image: busybox
    commands:
      - echo ${SHA}
    when:
      event: deployment
      environment: uat
```

Once you are ready, you can push the changes to the remote repository. In your main repository you can add the following step:

```yaml
trigger_deploy:
  image: quay.io/ukhomeofficedigital/drone-trigger:latest
  drone_server: https://drone.acp.homeoffice.gov.uk
  repo: UKHomeOffice/<deployment_repo>
  branch: <master>
  deploy_to: <uat>
  params: SHA=${DRONE_COMMIT_SHA}
  when:
    event: deployment
    environment: uat
```

The settings are very similar to the `drone deploy` command:

- `deploy_to` is the [environment constraint][drone docs - environment conditional]
- `params` is a list of comma separated list of arguments. In the command line tool, this is equivalent to `-p PARAM1=ONE -p PARAM2=TWO`
- `repo` the repository where the deployment scripts are located

The next time you trigger a deployment on the main repository with:

```bash
$ drone deploy UKHomeOffice/<your_repo> 16 uat
```

This will trigger a new deployment on the second repository.

Please note that in this scenario you need to inspect 2 builds on 2 separate repositories if you just want to inspect the logs.

#### Versioned deployments

When you restart your build, Drone will automatically use the latest version of the code. However always using the latest version of the deployment configuration can cause major issues and isn't recommended. For example when promoting from preprod to prod you want to use the preprod version of the deployment configuration. If you use the latest it could potentially break your production environment, especially as it won't necessarily have been tested.

To counteract this you should use a specific version of your deployment scripts. In fact, you should  `git checkout` the tag or sha as part of your deployment step.

Here is an example of this:

```yaml
predeploy_to_uat:
  image: plugins/git
  commands:
    - git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo>.git
  when:
    environment: uat
    event: deployment

deploy_to_uat:
  image: quay.io/ukhomeofficedigital/kd:v0.11.0
  secrets:
    - kube_server
    - kube_token
  commands:
    - apk update && apk add git
    - git checkout v1.1
    - ./deploy.sh
  when:
    environment: uat
    event: deployment
```

#### Migrating your pipeline

##### Secrets and Signing

It is no longer necessary to sign your `.drone.yml` so the `.drone.yml.sig` can be deleted. Secrets can be defined in the Drone UI or using the CLI. Secrets created using the UI will be available to push, tag and deployment events. To restrict to selected events, or to allow pull request builds to access secrets you must use the CLI.

Pipelines by default do not have access to any Drone secrets that you have added. You must now define which secrets a pipeline is allowed access to in a `secrets` section in your pipeline. Here is an example of a pipeline that has access to the `DOCKER_PASSWORD` secret which will be used to push an image to Quay:

```yaml
image_to_quay:
  image: quay.io/ukhomeofficedigital/drone-docker
  secrets:
    - docker_password
  environment:
    - DOCKER_USERNAME=ukhomeofficedigital+<your_robot_username>
  registry: quay.io
  repo: quay.io/ukhomeofficedigital/<your_quay_repo>
  tags:
    - latest
  when:
    branch: master
    event: push
```

> Note: Secrets names in the `secrets` section will have their names uppercased at runtime.

Organisation secrets are no longer available. This means that if you are using any organisation secrets such as `KUBE_TOKEN_DEV`, you will need to add a secret in Drone to replace it.

#### Docker-in-Docker

The Docker-in-Docker (dind) service is no longer required. Instead, change the Docker host to `DOCKER_HOST=tcp://172.17.0.1:2375` in the `environment` section of your pipline, and you will be able to access the shared Docker server on the drone agent. Note that it is only possible to run one Docker build at a time per Drone agent.

Since privileged mode was primarily used for docker in docker, you should remove the `privileged: true` line from your `.drone.yml`.

You can also use your freshly built image directly and run commands as part of your pipeline.

Example:

```yaml
pipeline:

  build_image:
    image: docker:18.03
    environment:
      - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
      - docker build -t hello_world .
    when:
      branch: master
      event: push

  test_image:
    image: hello_world
    commands:
      - ./run-hello-world.sh
    when:
      branch: master
      event: push
```


#### Services

If you use the `services` section of your `.drone.yml` it is possible to reference them using the DNS name of the service.

For example, if using the following section:

```yaml
services:
  database:
    image: mysql
```

The mysql server would be available on `tcp://database:3306`

#### Variable Escaping

Any Drone variables (secrets and environment variables) must now be escaped by having two $$ instead of one. Examples:

```yaml
${DOCKER_PASSWORD} --> $${DOCKER_PASSWORD}
${DRONE_TAG} --> $${DRONE_TAG}
${DRONE_COMMIT_SHA} --> $${DRONE_COMMIT_SHA}

```

## Scanning Images in Drone

ACP provides Anchore as scanning solution to images built into the Drone pipeline, allowing users to scan both ephemeral _(built within the context of the drone, but not pushed to a repository yet)_ as well and well any public images.

```YAML
pipeline:
  build:
    image: docker:17.09.0-ce
    environment:
    - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
    - docker build -t docker.digital.homeoffice.gov.uk/myimage:$${DRONE_BUILD_NUMBER} .

  scan:
    # The location of the drone plugin
    image: quay.io/ukhomeofficedigital/anchore-submission:latest
    # The optional path of a Dockerfile
    dockerfile: Dockerfile
    # Note the lack of double $ here (due to the way drone injects variables"
    image_name: docker.digital.homeoffice.gov.uk/myimage:${DRONE_BUILD_NUMBER}
    # This indicates we are willing tolerate any vulnerabilities which are below medium
    tolarates: medium
    # An optional whitelist (comman separated list of CVE's)
    whitelist: CVE_SOMENAME_1,CVE_SOMENAME_2
    # An optional whitelist file containing a list of CSV relative to the repo path
    whitelist_file: <PATH>
    # By default the pligin will exit will fail if any vulnerabilities are discovered which are not tolarated,
    # you change this behaviour by setting the bellow
    fail_on_detection: false
```

#### Q&As

##### Q: The build fails with _"ERROR: Insufficient privileges to use privileged mode"_

A: Remove `privileged: true` from your `.drone.yml`. As explained in the [migrating your pipeline section](#migrating-your-pipeline), the primary use of this was for Docker-in-Docker which is not required.

##### Q: The build fails with _"Cannot connect to the Docker daemon. Is the docker daemon running on this host?"_

A: Make sure that your steps contain the environment variable `DOCKER_HOST=tcp://172.17.0.1:2375` like in this case:

```yaml
my-build:
  image: docker:18.03
  environment:
    - DOCKER_HOST=tcp://172.17.0.1:2375
  commands:
    - docker build -t <image_name> .
  when:
    branch: master
    event: push
```

##### Q: The build fails when uploading to Quay with the error _"Error response from daemon: Get https://quay.io/v2/: unauthorized:..."_

A: This is likely because the secret wasn't added correctly or the password is incorrect. Check that the secret has been added to Drone and that you have added the `secrets` section in your `.drone.yaml` it to the pipeline that requires it.

##### Q: As part of my build process I have two `Dockerfiles` to produce a Docker image. How can I share files between builds in the same step?

A: When the pipeline starts, Drone creates a Docker data volume that is passed along all active steps in the pipeline. If the first step creates a `test.txt` file, the second step can use that file. As an example, this pipeline uses a two step build process:

```yaml
pipeline:

  first-step:
    image: busybox
    commands:
      - echo hello > test.txt
    when:
      branch: master
      event: push

  second-step:
    image: busybox
    commands:
      - cat test.txt
    when:
      branch: master
      event: push
```

##### Q: Should I use Gitlab with Quay?

A: Please don't. If your repository is hosted in Gitlab then use Artifactory to publish your images. Images published to Artifactory are kept private.

If you still want to use Quay, you should consider hosting your repository on the open (Github).

##### Q: Can I create a token that has permission to create ephemeral/temporary namespaces?

A: No. This is because there is currently no way to give access to namespaces via regex.

I.e. There is no way to give access to any namespace with the format: `my-temp-namespace-*` (where \* would be build number or something similar).

Alternatively, you can be given a named namespace in the CI cluster. Please create an issue on our [BAU board][bau repo] if you require this.

[drone docs - cli install]: https://docs.drone.io/cli-installation/
[drone cli releases]: https://github.com/drone/drone-cli/releases
[drone github token page]: https://drone.acp.homeoffice.gov.uk/account/token
[drone github repos page]: https://drone.acp.homeoffice.gov.uk/account/repos
[quay link]: https://quay.io
[add to quay support request]: https://hub.acp.homeoffice.gov.uk/help/support/requests/new/add-to-quay-org
[quay robot support request]: https://hub.acp.homeoffice.gov.uk/help/support/requests/new/quay-robot-request
[artifactory link]: https://docker.digital.homeoffice.gov.uk
[artifactory support request]: https://hub.acp.homeoffice.gov.uk/help/support/requests/new/artifactory-token
[drone docs - environments]: http://docs.drone.io/environment/
[drone docs - conditions]: http://docs.drone.io/conditional-steps/
[kube signed commit check repo]: https://github.com/UKHomeOffice/kube-signed-commit-check
[kd repo]: https://github.com/UKHomeOffice/kd
[kube token how to]: kubernetes-user-token.md
[drone-trigger repo]: https://github.com/UKHomeOffice/drone-trigger
[drone docs - environment conditional]: http://docs.drone.io/conditional-steps/#environment
[bau repo]: https://github.com/UKHomeOffice/application-container-platform-bau
