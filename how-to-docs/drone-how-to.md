# Drone CI Guide

- Setup
  - [Install Drone CLI](#install-drone-cli)
  - [Activate your pipeline](#activate-your-pipeline)
- Adding a repository to Drone
  - [Configure your pipeline](#configure-your-pipeline)
  - [Signature](#signature)
- Publishing Docker images to
  - [Quay](#publishing-to-quay)
  - [Artifactory](#publishing-to-artifactory)
- Deployments
  - [Deployments and promotions](#deployments-and-promotions)
  - [Deploying to DSP](#deploying-to-dsp)
  - [Versioned deployments](#versioned-deployments)
  - [Ephemeral deployments](#ephemeral-deployments)
- Pull requests
  - [PR Builder](#drone-as-a-pull-request-builder)
- [QAs](#qas)
- [Snippets](drone-snippets.md)

## Install Drone CLI

- [Github drone instance](https://drone.digital.homeoffice.gov.uk): https://drone.digital.homeoffice.gov.uk
- [Gitlab drone instance](https://drone-gitlab.digital.homeoffice.gov.uk/): https://drone-gitlab.digital.homeoffice.gov.uk/

Download and install the [Drone CLI](http://readme.drone.io/0.5/install/cli/) from the official website.

> **Please don't install Drone CLI with `brew`** .
> At the time of writing `brew` installs an old version of Drone that is not compatible with Drone 0.5.

Verify it works as expected:

```bash
$ drone --version
drone version 0.5.0+dev
```

Export the `DRONE_SERVER` and `DRONE_TOKEN` variables. You can find your token on the top left corner in your [account page](https://drone.digital.homeoffice.gov.uk/account).

```bash
export DRONE_SERVER=https://drone.digital.homeoffice.gov.uk
export DRONE_TOKEN=123_your_token
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

## Activate your pipeline

Once you are logged in, navigate to your [Account](https://drone.digital.homeoffice.gov.uk/account) from the top right corner.

Select the repo you want to activate.

Navigate to your repository's settings in Github (or Gitlab) and update the payload url in the web hook section so that it matches this pattern:

```
https://drone-external.digital.homeoffice.gov.uk/hook?access_token=some_token
```



## Configure your pipeline

In the root folder of your project, create a `.drone.yml` file with the following content:

```yaml
pipeline:

  my-build:
    privileged: true
    image: docker:1.11
    environment:
      - DOCKER_HOST=tcp://127.0.0.1:2375
    commands:
      - docker build -t <image_name> .
    when:
      branch: master
      event: push

services:
  dind:
    image: docker:1.11-dind
    privileged: true
    command:
      - "-s"
      - "overlay"
```

Commit and push your changes:

```bash
$ git add .drone.yml
$ git commit
$ git push origin master
```

> **Please note** you should replace the name <...> with the name of your app.

After you pushed, you should be able to see the build failing in Drone with the following message:

```bash
ERROR: Insufficient privileges to use privileged mode
```

The current configuration requires extended privileges to run, but you're repository is not trusted. With a little help from Devops you should get your repository whitelisted.

Once you are good to go, you can trigger a new build by pushing a new commit or through the Drone UI.

This time the build will succeed.

## Signature

Drone requires you to sign the Yaml file before injecting secrets into your build environment. You can generate a signature for a named repository like this:

```bash
$ drone sign UKHomeOffice/<your_repo>
```

This will create a `.drone.yml.sig` in the current directory. You should commit this file:

```bash
$ git add .drone.yml.sig
$ git commit
$ git push origin master
```

You must re-sign your `.drone.yml` every time you change it.

## Publishing to Quay

If your repository is hosted on Gitlab, you don't want to publish your images to Quay. Images published to Quay are public and can be inspected and downloaded by anyone. [You should publish your private images to Artifactory](#publishing-to-artifactory).

Register for a free [Quay account](https://quay.io) using your Github account linked to the Home Office organisation.

Once you've logged into Quay check that you have `ukhomeofficedigital` under Users and Organisations.  
If you do not, [make a request by adding an issue to the Platform Access column] (https://github.com/UKHomeOffice/hosting-platform-bau/projects/1)

Once you have access to view the `ukhomeofficedigital` repositories, click repositories and
click the `+ Create New Repositories` that is:

- public
- empty - no need to create a repo from a Dockerfile or link it to an existing repository

Add your project to the UKHomeOffice Quay account

[Raise a ticket for a new UKHomeOffice Quay robot in the Platform Access column](https://github.com/UKHomeOffice/hosting-platform-bau/projects/1). You have to pick a name for it.  You should be supplied a robot password in response.

Add the step to publish the docker image to Quay in your Drone pipeline with the supplied docker login but NOT the password:

```yaml
image_to_quay:
  image: docker:1.11
  environment:
    - DOCKER_HOST=tcp://127.0.0.1:2375
  commands:
    - docker login -u="ukhomeofficedigital+drone_demo" -p=${DOCKER_PASSWORD} quay.io
    - docker tag <image_name> quay.io/ukhomeofficedigital/<node-hello-world>:${DRONE_COMMIT_SHA}
    - docker push quay.io/ukhomeofficedigital/<node-hello-world>:${DRONE_COMMIT_SHA}
  when:
    branch: master
    event: push
```

Where the `image_name` in:

```yaml
docker tag image_name quay.io/ukhomeofficedigital/<node-hello-world>:${DRONE_COMMIT_SHA}
```

is the name of the image you tagged previously in the build step.

Since your `.drone.yml`  has changed, you have to sign it before you can push the repository to the remote:

```
$ drone sign UKHomeOffice/<your_repo>
$ git add .drone.yml.sig
$ git add .drone.yml
$ git commit
$ git push origin master
```

The build should fail with the following error:

```bash
docker login -u="ukhomeofficedigital+<drone>" -p=${DOCKER_PASSWORD} quay.io
inappropriate ioctl for device
```

The error points to the missing `DOCKER_PASSWORD` environment variable.

You can inject the robot's password supplied to you in your raised ticket to the Platform team with:

```
$ drone secret add --conceal --image="<your_image>" UKHomeOffice/<your_repo> DOCKER_PASSWORD your_robot_token
```

Restarting the build should be enough to make it pass.

## Publishing to Artifactory

Images hosted on [Artifactory](https://docker.digital.homeoffice.gov.uk) are private.

If your repository is hosted publicly on GitHub, you shouldn't publish your images to Artifactory. Artifactory is only used to publish private images. [You should use Quay to publish your public images](#publishing-to-quay).

[Raise a ticket for a new Artifactory robot](https://github.com/UKHomeOffice/hosting-platform-bau/). You have to pick a name for it.  You should be supplied a robot token in response.

You can inject the robot's token supplied to you in your raised ticket to the Platform team with:

```
$ drone secret add --image="<your_image>" UKHomeOffice/<your_repo> DOCKER_ARTIFACTORY_PASSWORD your_robot_token
```

You can add the following step in your `.drone.yml`:

```yaml
image_to_artifactory:
  image: docker:1.11
  environment:
    - DOCKER_HOST=tcp://127.0.0.1:2375
  commands:
    - docker login -u="<your_robot_user>" -p=${DOCKER_ARTIFACTORY_PASSWORD} docker.digital.homeoffice.gov.uk
    - docker tag image_name docker.digital.homeoffice.gov.uk/ukhomeofficedigital/<node-hello-world>:${DRONE_COMMIT_SHA}
    - docker push docker.digital.homeoffice.gov.uk/ukhomeofficedigital/<node-hello-world>:${DRONE_COMMIT_SHA}
  when:
    branch: master
    event: push
```

Where the `image_name` in:

```yaml
docker tag image_name quay.io/ukhomeofficedigital/<node-hello-world>:${DRONE_COMMIT_SHA}
```

is the name of the image you tagged previously in the build step.

Since your `.drone.yml`  has changed, you have to sign it before you can push the repository to the remote:

```bash
$ drone sign UKHomeOffice/<your_repo>
$ git add .drone.yml.sig
$ git add .drone.yml
$ git commit
$ git push origin master
```

The image should now be published on Artifactory.

## Deployments and promotions

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

Sign your build and push the changes to your remote repository.

You can deploy the build you just pushed with the following command:

```bash
$ drone deploy UKHomeOffice/<your_repo> 16 preprod
```

Where `16` is the successful build number you wish to deploy to the `preprod` environment.

You can pass additional arguments to your deployment as environment variables:

```bash
$ drone deploy UKHomeOffice/<your_repo> 16 preprod -p DEBUG=1 -p NAME=Dan
```

and use from the step like this:

```yaml
deploy-to-preprod:
  image: busybox
  commands:
    - /bin/echo hello ${NAME}
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
$ drone deploy UKHomeOffice/<your_repo> 15 preprod
$ drone deploy UKHomeOffice/<your_repo> 16 prod
```

[Read more on environment and constraints](http://readme.drone.io/0.5/usage/constraints/#environment)

## Drone as a Pull Request builder

Drone pipelines are triggered when events occurs. Event triggers can be as simple as a _push_, _a tagged commit_ or _a pull request_ or as granular as _only for pull request with a named branch `test`_. You can limit the execution of build steps at runtime using the `when` block. As an example, this block executes only on pull requests:

```yaml
pr-builder:
  privileged: true
  image: docker:1.11
  environment:
    - DOCKER_HOST=tcp://127.0.0.1:2375
  commands:
    - docker build -t <node-hello-world> .
  when:
    event: pull_request
```

Drone will automatically execute that step when a new pull request is raised.

[> Read more about Drone conditions](http://readme.drone.io/0.5/usage/conditions/)

## Deploying to DSP

> Please note that this section assumes you have a separate repository containing your kube files as explained [here](https://github.com/UKHomeOffice/hosting-platform/blob/master/developer-docs/platform_introduction.md#define-a-deployment-for-your-application).

You can clone your kube repo as part of your pipeline with:

```yaml
predeploy_to_uat:
  image: plugins/git
  commands:
    - git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo>.git
  when:
    environment: uat
    event: deployment
```

from now on, the repository is part of the workspace and is ready to be accessed by other steps in the pipeline.

You can execute the deployment script in a new step with:

```yaml
deploy_to_uat:
  image: quay.io/ukhomeofficedigital/kd:v0.2.3
  environment:
    - KUBE_NAMESPACE=<dev-induction>
  commands:
    - cd <kube-node-hello-world>
    - ./deploy.sh
  when:
    environment: uat
    event: deployment
```

The build will fail with the following error:

```bash
[INFO] 2016/10/20 10:17:40 main.go:158: deploying deployment/induction-hello-world
[ERROR] 2016/10/20 10:17:40 main.go:160: error: You must be logged in to the server (the server has asked for the client to provide credentials)
[ERROR] 2016/10/20 10:17:40 main.go:130: exit status 1
```

This suggests that you are not authorised to deploy to the kubernetes cluster. You can fix this by setting your `KUBE_TOKEN` to a valid value. But before you do this, let's recap the environment variables needed to deploy successfully to DSP.

The kube `deploy.sh` scripts relies on 3 environment variables:

- `KUBE_NAMESPACE` - the kubernetes namespace you wish to deploy to. **You need to provide the kubernetes namespace as part of the deployment job**.

- `KUBE_TOKEN` - this is the token used to authenticate against the kubernetes cluster. **You need to add this as a secret to your build step. You can [request a kubernetes token here](https://github.com/UKHomeOffice/hosting-platform-bau/issues/new)**. In this particular case, the secret was added with:

  ```bash
  $ drone secret add --image=quay.io/ukhomeofficedigital/kd:v0.2.3 --conceal  UKHomeOffice/<your_repo> KUBE_TOKEN <your_token>
  ```

- `KUBE_SERVER` - this is the address of the kubernetes cluster. There are four environment variables set as an organisational secret in Drone: `KUBE_SERVER_DEV`,  `KUBE_SERVER_OPS`, `KUBE_SERVER_PROD` and `KUBE_SERVER_CI`. You can verify that the secrets are present with:

  ```
  $ drone org secret ls UKHomeOffice
  ```

  _Please note that you need to be an admin to issue this command._

You need to reassign one of those four variables to `KUBE_SERVER` before your script runs, [like in this case](https://github.com/UKHomeOffice/kube-node-hello-world/blob/99af304ce0b894e8f0db1c05780cf6512741516d/deploy.sh#L4).

Restarting the build should be enough to see it succeed.

## Versioned deployments

In the previous step you learnt how to `git checkout` another repository and deploy your app to DSP. Since there's no tag nor commit on the repository url, the `predeploy_uat` step always checks out the latest code:

```yaml
predeploy_to_uat:
  image: plugins/git
  commands:
    - git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo>.git
  when:
    environment: uat
    event: deployment
```

This is convenient if you change your deployment repository frequently, since drone will checkout the latest code every time you restart the build.

However always using the latest version of the deployment configuration can cause major issues and isn't recommended. For example when promoting from preprod to prod you want to use the preprod version of the deployment configuration. If you use the latest it could potentially break your production environment, especially as it won't necessarily have been tested.

To counteract this you should use a specific version of your deployment scripts. In fact, you should  `git checkout` the tag or sha as part of your deployment step.

This is how the new pipeline would look like:

```yaml
predeploy_generic:
  image: plugins/git
  commands:
    - git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo>.git
  when:
    event: deployment

deploy_to_uat:
  image: quay.io/ukhomeofficedigital/kd:v0.2.3
  environment:
    - KUBE_NAMESPACE=<dev-induction>
  commands:
    - cd <kube-node-hello-world>
    - git checkout v1.1
    - ./deploy.sh
  when:
    environment: uat
    event: deployment
```

## Ephemeral deployments

Sometimes you might want to start more than one service and test how those services interact with each other. This is particularly useful when you want to run integration or end-to-end tests as part of your pipeline.

You can deploy your application to a temporary namespace in the cluster, run the test and dispose of the environment as part of your pipeline.

You should already have kubernetes configs for deployment, service and ingress. In order to create an environment from scratch you need all your kubernetes secrets to be loaded as part of the startup process.

Kubernetes secrets can be loaded in your environment using a configuration (yaml) file or inline. You can find more information setting secrets [here](https://github.com/UKHomeOffice/hosting-platform/blob/master/developer-docs/platform_introduction.md#create-a-kubernetes-secret). We recommend you create a `secrets.yaml` as a template for your secrets.

```yaml
  deploy_to_ci:
    image: quay.io/ukhomeofficedigital/kd:v0.2.3
    commands:
      - |
        export KUBE_NAMESPACE="<your-project-name>-$(head /dev/urandom | tr -dc a-z0-9 | head -c 13)"
        export KUBE_SERVER=${KUBE_SERVER_CI}
        export KUBE_TOKEN=${KUBE_TOKEN_CI}
        export MY_SECRET=$(head /dev/urandom | tr -dc a-z0-9 | head -c 13 | base64)

        echo ${KUBE_NAMESPACE} > namespace.txt

        kubectl create namespace ${KUBE_NAMESPACE} --insecure-skip-tls-verify=true --server=${KUBE_SERVER} --token=${KUBE_TOKEN}
        cd kube-node-hello-world

        cd kube
        kd --insecure-skip-tls-verify \
           --file example-secrets.yaml \
           --file example-deployment.yaml \
           --file example-service.yaml \
           --file example-ingress.yaml
    when:
      branch: master
      event: push

  tidy_up:
    image: quay.io/ukhomeofficedigital/kd:v0.2.3
    commands:
      - |
        export KUBE_NAMESPACE=`cat namespace.txt`
        export KUBE_SERVER=${KUBE_SERVER_CI}
        export KUBE_TOKEN=${KUBE_TOKEN_CI}
        kubectl delete namespace ${KUBE_NAMESPACE} --insecure-skip-tls-verify=true --server=${KUBE_SERVER} --token=${KUBE_TOKEN}
    when:
      branch: master
      event: push
      status: [ success, failure ]
```

These are the variables used:

- `KUBE_TOKEN_CI` is provided to you as global secret. This is used to authenticate to the Kubernetes cluster. There's no need to set this yourself.
- `KUBE_SERVER_CI` is the url for one of the four clusters (the other three being DEV, PREPROD & PROD). This is a global secret and there's no need to set this yourself.
- `KUBENAMESPACE` is the name for the Kubernetes namespace. The name is created dynamically using `uuidgen`, but you could use any function you wish as long as the string is unique _enough_.
- `DB_USERNAME` and `DB_PASSWORD` are base64 strings used to store username and password for the database. Those secrets are passed into the `example-secrets.yml` and deployed to the namespace. Since we don't care about the value for those secrets, the content is created pseudo randomly with `uuidgen`.

The `tidy_up` step is configured to run on successful and failed builds and removes the generated namespace.

You can run tests or any other task that interacts with the deployed service by adding a step in the pipeline between the `deploy_to_ci` and `tidy_up`. As an example, you can `curl` the service to probe its liveness:

```
  deploy_to_ci:
    image: quay.io/ukhomeofficedigital/kd:v0.2.3
    ...

  test_all_the_things:
    image: busybox
    commands:
      - |
        export KUBE_NAMESPACE=`cat namespace.txt`
        curl "<your-project>-${KUBE_NAMESPACE}.notprod.homeoffice.gov.uk"
    when:
      branch: master
      event: push

  tidy_up:
    image: quay.io/ukhomeofficedigital/kd:v0.2.3
    ...

```

You can customise the url of the service in your ingress manifest.



## Q&As

### Q: The build fails with _"ERROR: Insufficient privileges to use privileged mode"_

A: Your repository isn't in the trusted list of repositories. Get in touch with Devops and ask them to trust it.

### Q: The build fails with _"Cannot connect to the Docker daemon. Is the docker daemon running on this host?"_

A: Make sure that your steps contain the environment variable `DOCKER_HOST=tcp://127.0.0.1:2375` like in this case:

````
my-build:
  privileged: true
  image: docker:1.11
  environment:
    - DOCKER_HOST=tcp://127.0.0.1:2375
  commands:
    - docker build -t <image_name> .
  when:
    branch: master
    event: push
````

Also make sure that you have `dind` as a service in your `.drone.yml`:

```
services:
  dind:
    image: docker:1.11-dind
    privileged: true
    command:
      - "-s"
      - "overlay"
```

### Q: The build fails when uploading to Quay with the error _"Inappropriate ioctl for device"_

A: This suggests that the `docker` executable prompted for credentials instead of reading them from the command line. This might be caused by:

- Your `.drone.yml` not being signed. When you want to inject environment variables in your build you must sign your `.drone.yml`.
- The secret wasn't injected correctly or the password is incorrect.

### Q: As part of my build process I have two `Dockerfile`s to produce a Docker image. How can I share files between builds in the same step?

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

### Q : What shall I do when my deployment scripts are in another repo?

A: You can clone another repo in the current repo using the following step:

```yaml
predeploy_to_uat:
  image: plugins/git
  commands:
    - git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo>.git
  when:
    environment: uat
    event: deployment
```
Note if you happen to have private GitLab repository, you do not need x-oauth-basic authencation. So the step would look like:

```yaml
predeploy_to_uat:
  image: plugins/git
  commands:
    - git clone https://gitlab.digital.homeoffice.gov.uk/<your_repo>.git
  when:
    environment: uat
    event: deployment
```

Your repository is saved in the workspace, which in turn is shared among all steps in the pipeline.

This is the preferred way to deploy our code since you need to maintain one single `.drone.yml`.

However, if you decide that you want to trigger a completely different pipeline on a separate repository, you can leverage the [drone-trigger](https://github.com/UKHomeOffice/drone-trigger) plugin. If you have a secondary repository, you can setup Drone on that repository like so:

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

Once you are ready, you can sign the `.drone.yml` and push the changes to the remote repository. In your main repository you can add the following step:

```yaml
trigger_deploy:
  image: quay.io/ukhomeofficedigital/drone-trigger:latest
  drone_server: https://drone.digital.homeoffice.gov.uk
  repo: UKHomeOffice/<deployment_repo>
  branch: <master>
  deploy_to: <uat>
  params: SHA=${DRONE_COMMIT_SHA}
  when:
    event: deployment
    environment: uat
```

The settings are very similar to the `drone deploy` command:

- `deploy_to` is the [environment constraint](http://readme.drone.io/0.5/usage/constraints/#environment)
- `params` is a list of comma separated list of arguments. In the command line tool, this is equivalent to `-p PARAM1=ONE -p PARAM2=TWO`
- `repo` the repository where the deployment scripts are located

The next time you trigger a deployment on the main repository with:

```bash
$ drone deploy UKHomeOffice/<your_repo> 16 uat
```

This will trigger a new deployment on the second repository.

Please note that in this scenario you need to inspect 2 builds on 2 separate repositories if you just want to inspect the logs.

## Q: I can't sign `.drone.yml`

- Make sure that your repository is activated in Drone
- Make sure your `DRONE_SERVER` and `DRONE_TOKEN` are properly set
- Make sure you can successfully connect to Drone by typing `drone info`

## Q: Should I use Gitlab with Quay?

A: Please don't. If your repository is hosted in Gitlab then use Artifactory to publish your images. Images published to Artifactory are kept private.

If you still want to use Quay, you should consider hosting your repository on the open (Github).
