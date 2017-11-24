# Drone CI Guide

- Setup
  - [Install Drone CLI](#install-drone-cli)
  - [Activate your pipeline](#activate-your-pipeline)
- Adding a repository to Drone
  - [Configure your pipeline](#configure-your-pipeline)
- Publishing Docker images to
  - [Quay](#publishing-to-quay)
  - [Artifactory](#publishing-to-artifactory)
- Deployments
  - [Deployments and promotions](#deployments-and-promotions)
  - [Drone as a pull request builder](#drone-as-a-pull-request-builder)
  - [Deploying to ACP](#deploying-to-acp)
  - [Versioned deployments](#versioned-deployments)
  - [Ephemeral deployments](#ephemeral-deployments)
  - [Using Another Repo](#using-another-repo)
- Migrating your Pipeline
  - [Secrets and Signing](#secrets-and-signing)
  - [Docker in Docker](#docker-in-docker)
  - [Services](#services)
- [QAs](#qas)
- [Snippets](drone-snippets.md)

## Setup

### Install Drone CLI

- Github drone instance: https://drone.acp.homeoffice.gov.uk/
- Gitlab drone instance: https://drone-gitlab.acp.homeoffice.gov.uk/

Download and install the [Drone CLI](http://docs.drone.io/cli-installation/).

> At the time of writing, we are using version 0.8 of Drone.

You can also install a release from [Drone CLI's GitHub repo](https://github.com/drone/drone-cli/releases).
Once you have downloaded the relevant file, extract it and move it to the `/usr/local/bin` directory.


Verify it works as expected:

```bash
$ drone --version
drone version 0.8.0
```

Export the `DRONE_SERVER` and `DRONE_TOKEN` variables. You can find your token on Drone by clicking the icon in the top right corner and going to [Token](https://drone.acp.homeoffice.gov.uk/account/token).

```bash
export DRONE_SERVER=https://drone.acp.homeoffice.gov.uk
export DRONE_TOKEN=your_drone_token
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

### Activate your pipeline

Once you are logged in to Drone, you will find a list of repos by clicking the icon in the top right corner and going to [Repositories](https://drone.acp.homeoffice.gov.uk/account/repos).

Select the repo you want to activate.

Navigate to your repository's settings in Github (or Gitlab) and update the payload url in the web hook section so that it matches this pattern:

```
https://drone-external.acp.homeoffice.gov.uk/hook?access_token=some_token
```

> If it is already in that format there is no need to change anything.
>
> The token in the payload url will not be the same as the personal token that you exported and it should be left unchanged.

### Configure your pipeline

In the root folder of your project, create a `.drone.yml` file with the following content:

```yaml
pipeline:
  my-build:
    image: docker:17.09.0-ce
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

You should be able to watch your build succeed in the drone UI.

## Publishing Docker images

### Publishing to Quay

If your repository is hosted on Gitlab, you don't want to publish your images to Quay. Images published to Quay are public and can be inspected and downloaded by anyone. [You should publish your private images to Artifactory](#publishing-to-artifactory).

Register for a free [Quay account](https://quay.io) using your Github account linked to the Home Office organisation.

Once you've logged into Quay check that you have `ukhomeofficedigital` under Users and Organisations.  
If you do not, [submit a support request on the platform hub for access to the ukhomeoffice organisation](https://hub.acp.homeoffice.gov.uk/help/support/requests/overview).

Once you have access to view the `ukhomeofficedigital` repositories, click repositories and
click the `+ Create New Repositories` that is:

- public
- empty - no need to create a repo from a Dockerfile or link it to an existing repository

Add your project to the UKHomeOffice Quay account and [submit a support request on the platform hub for a new Quay robot](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/quay-robot-request).

Add the step to publish the docker image to Quay in your Drone pipeline with the supplied docker login but NOT the password:

```yaml
image_to_quay:
  image: docker:17.09.0-ce
  environment:
    - DOCKER_HOST=tcp://172.17.0.1:2375
  commands:
    - docker login -u="ukhomeofficedigital+<your_robot_username>" -p=$${DOCKER_PASSWORD} quay.io
    - docker tag <image_name> quay.io/ukhomeofficedigital/<your_quay_repo>:$${DRONE_COMMIT_SHA}
    - docker push quay.io/ukhomeofficedigital/<your_quay_repo>:$${DRONE_COMMIT_SHA}
  when:
    branch: master
    event: push
```

Where the `<image_name>` in:

```yaml
docker tag <image_name> quay.io/ukhomeofficedigital/<your_quay_repo>:${DRONE_COMMIT_SHA}
```

is the name of the image you tagged previously in the build step.

> Note: $${DRONE_COMMIT_SHA} is a Drone environment variable that is passed to the container at runtime.

The build should fail with the following error:

```bash
docker login -u="ukhomeofficedigital+<your_robot_username>" -p=$${DOCKER_PASSWORD} quay.io
inappropriate ioctl for device
```

The error points to the missing `DOCKER_PASSWORD` environment variable.

You can inject the robot's token that has been supplied to you with:

```
$ drone secret add --image="<image_name>" --repository ukhomeoffice/<your_github_repo> --name DOCKER_PASSWORD --value your_robot_token
```

Restarting the build should be enough to make it pass.

### Publishing to Artifactory

Images hosted on [Artifactory](https://docker.digital.homeoffice.gov.uk) are private.

If your repository is hosted publicly on GitHub, you shouldn't publish your images to Artifactory. Artifactory is only used to publish private images. [You should use Quay to publish your public images](#publishing-to-quay).

[Submit a support request for a new Artifactory robot](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/artifactory-bot). You should be supplied a robot token in response.

You can inject the robot's token that has been supplied to you with:

```
$ drone secret add --image="<image_name>" --repository ukhomeoffice/<your_gitlab_repo> --name DOCKER_ARTIFACTORY_PASSWORD --value your_robot_token
```

You can add the following step in your `.drone.yml`:

```yaml
image_to_artifactory:
  image: docker:17.09.0-ce
  environment:
    - DOCKER_HOST=tcp://172.17.0.1:2375
  commands:
    - docker login -u="<your_robots_username>" -p=$${DOCKER_ARTIFACTORY_PASSWORD} docker.digital.homeoffice.gov.uk
    - docker tag <image_name> docker.digital.homeoffice.gov.uk/ukhomeofficedigital/<your_artifactory_repo>:$${DRONE_COMMIT_SHA}
    - docker push docker.digital.homeoffice.gov.uk/ukhomeofficedigital/<your_artifactory_repo>:$${DRONE_COMMIT_SHA}
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

## Deployments

### Deployments and promotions

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
$ drone deploy ukhomeoffice/<your_repo> 15 preprod
$ drone deploy ukhomeoffice/<your_repo> 16 prod
```

Read more on [environments](http://docs.drone.io/environment/).

### Drone as a Pull Request builder

Drone pipelines are triggered when events occurs. Event triggers can be as simple as a _push_, _a tagged commit_, _a pull request_ or as granular as _only for pull requests for a branch named `test`_. You can limit the execution of build steps at runtime using the `when` block. As an example, this block executes only on pull requests:

```yaml
pr-builder:
  privileged: true
  image: docker:17.09.0-ce
  environment:
    - DOCKER_HOST=tcp://172.17.0.1:2375
  commands:
    - docker build -t <image_name> .
  when:
    event: pull_request
```

Drone will automatically execute that step when a new pull request is raised.

[Read more about Drone conditions](http://docs.drone.io/conditional-steps/).

### Deploying to ACP

Add a deployment script with the following:
 
```bash
#!/bin/bash
export KUBE_NAMESPACE=<dev-induction>
export KUBE_SERVER=${KUBE_SERVER}
export KUBE_TOKEN=${KUBE_TOKEN}
  
kd --insecure-skip-tls-verify \
    -f deployment.yaml \
    -f service.yaml \
    -f ingress.yaml
```

> Please note that this is only an example script and it will need to be changed to fit your particular application's needs.

If you deployed this now you would likely receive an error similar to this:

```bash
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

This error appears because [kd](https://github.com/UKHomeOffice/kd) needs 3 environment variables to be set before deploying:

- `KUBE_NAMESPACE` - The kubernetes namespace you wish to deploy to. **You need to provide the kubernetes namespace as part of the deployment job**.

- `KUBE_TOKEN` - This is the token used to authenticate against the kubernetes cluster. **If you do not already have a kube token, [here are docs explaining how to get one](https://github.com/UKHomeOffice/application-container-platform/blob/master/how-to-docs/kubernetes-token.md)**.

- `KUBE_SERVER` - This is the address of the kubernetes cluster that you want to deploy to.

You will need to add `KUBE_TOKEN` and `KUBE_SERVER` as drone secrets.

You can add and view a list of secrets through the Drone UI. Go to Drone and select your repo, then click the icon in the top right and select **Secrets**. You should be presented with a list of the secrets for that repo (if there are any) and you should be able to add secrets giving them a name and value. Add the `KUBE_TOKEN` and `KUBE_SERVER` secrets with their respective values.

Alternatively, you can use this command to add the `KUBE_TOKEN` secret:

```bash
$ drone secret add --image quay.io/ukhomeofficedigital/kd:v0.2.3 --repository ukhomeoffice/<your_repo> --name KUBE_TOKEN --value <your_token>
```

Adding the `KUBE_SERVER` will be similar.

You can verify that the secrets for your repo are present with:

```bash
$ drone secret ls ukhomeoffice/<your-repo>
```

_Please note that you need to be an admin to issue this command._


Once the secrets have been added, add a new step to your drone pipeline that will execute the deployment script:

```yaml
deploy_to_uat:
  image: quay.io/ukhomeofficedigital/kd:v0.2.3
  secrets:
    - kube_server
    - kube_token
  commands:
    - ./deploy.sh
  when:
    environment: uat
    event: deployment
```

### Versioned deployments

When you restart your build, Drone will automatically use the latest version of the code. However always using the latest version of the deployment configuration can cause major issues and isn't recommended. For example when promoting from preprod to prod you want to use the preprod version of the deployment configuration. If you use the latest it could potentially break your production environment, especially as it won't necessarily have been tested.

To counteract this you should use a specific version of your deployment scripts. In fact, you should  `git checkout` the tag or sha as part of your deployment step.

This is how the new pipeline would look:

```yaml
deploy_to_uat:
  image: quay.io/ukhomeofficedigital/kd:v0.2.3
  secrets:
    - kube_server
    - kube_token
  commands:
    - git checkout v1.1
    - ./deploy.sh
  when:
    environment: uat
    event: deployment
```

### Ephemeral deployments

Sometimes you might want to start more than one service and test how those services interact with each other. This is particularly useful when you want to run integration or end-to-end tests as part of your pipeline.

You can deploy your application to a temporary namespace in the cluster, run the test and dispose of the environment as part of your pipeline.

You should already have kubernetes configs for deployment, service and ingress. In order to create an environment from scratch you need all your kubernetes secrets to be loaded as part of the startup process.

Kubernetes secrets can be loaded in your environment using a configuration (yaml) file or inline. You can find more information setting secrets [here](https://github.com/UKHomeOffice/application-container-platform/blob/master/developer-docs/platform_introduction.md#create-a-kubernetes-secret). We recommend you create a `secrets.yaml` as a template for your secrets.

```yaml
  deploy_to_ci:
    image: quay.io/ukhomeofficedigital/kd:v0.2.3
    commands:
      - |
        export KUBE_NAMESPACE="<your-project-name-temp>"
        export KUBE_SERVER=${KUBE_SERVER}
        export KUBE_TOKEN=${KUBE_TOKEN}

        echo ${KUBE_NAMESPACE} > namespace.txt

        kubectl create namespace ${KUBE_NAMESPACE} --insecure-skip-tls-verify=true --server=${KUBE_SERVER} --token=${KUBE_TOKEN}

        kd --insecure-skip-tls-verify \
           --file secrets.yaml \
           --file deployment.yaml \
           --file service.yaml \
           --file ingress.yaml
    when:
      branch: master
      event: push

  tidy_up:
    image: quay.io/ukhomeofficedigital/kd:v0.2.3
    commands:
      - |
        export KUBE_NAMESPACE=`cat namespace.txt`
        export KUBE_SERVER=${KUBE_SERVER}
        export KUBE_TOKEN=${KUBE_TOKEN}
        kubectl delete namespace ${KUBE_NAMESPACE} --insecure-skip-tls-verify=true --server=${KUBE_SERVER} --token=${KUBE_TOKEN}
    when:
      branch: master
      event: push
      status: [ success, failure ]
```

The `tidy_up` step is configured to run on successful and failed builds and removes the generated namespace.

> Please note that this is only an example. Parts of this will need to be modified depending on your application. `KUBE_SERVER` AND `KUBE_TOKEN` will need to be set as Drone secrets similar to how they were set in the [Deploying to ACP section](#deploying-to-acp).

You can run tests or any other task that interacts with the deployed service by adding a step in the pipeline between the `deploy_to_ci` and `tidy_up`. As an example, you can use `wget` to check that your service works:

```yaml
  deploy_to_ci:
    image: quay.io/ukhomeofficedigital/kd:v0.2.3
    ...

  test_all_the_things:
    image: busybox
    network_mode: "default"
    commands:
      - |
        start=$SECONDS
        timeout=60
        (exit 9)
        while [ $? -ne 0  ]
        do
          if [ (( $SECONDS - $start )) -ge $timeout ]
          then
            break
          fi
          wget -O- "<your-service-host-url>"
        done
    when:
      branch: master
      event: push

  tidy_up:
    image: quay.io/ukhomeofficedigital/kd:v0.2.3
    ...
```

Please note that `network_mode` and `dns` are required to resolve the name of the service from within the Drone agent.

You can find the name of your service at the very top of your service kube file:

```Yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    name: <name-of-your-service>
  name: <name-of-your-service>
...
```

### Using Another Repo

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

- `deploy_to` is the [environment constraint](http://docs.drone.io/conditional-steps/#environment)
- `params` is a list of comma separated list of arguments. In the command line tool, this is equivalent to `-p PARAM1=ONE -p PARAM2=TWO`
- `repo` the repository where the deployment scripts are located

The next time you trigger a deployment on the main repository with:

```bash
$ drone deploy UKHomeOffice/<your_repo> 16 uat
```

This will trigger a new deployment on the second repository.

Please note that in this scenario you need to inspect 2 builds on 2 separate repositories if you just want to inspect the logs.

## Migrating your pipeline

### Secrets and Signing

It is no longer necessary to sign your `.drone.yml` so the `.drone.yml.sig` can be deleted. Secrets can be defined in the drone UI and can be restricted to selected events, for example deployments or pull requests. See [location] for an example of this

### Docker-in-Docker

The Docker-in-Docker (dind) service is no longer required. Instead, add `DOCKER_HOST=tcp://172.17.0.1:2375` to the `envionment` section of your pipline, and you will be able to access the shared Docker server on the drone agent. Note that it is only possible to run one docker build at a time per drone agent.

Since priviliged mode was primarily used for docker in docker, in most cases it should be possible to remove the `priviliged: true` line from your .drone.yml

### Services

If you use the `services` section of your `.drone.yml` it is possible to reference them using the DNS name of the service. 

For example, if using the following section:

```
services:
  database:
    image: mysql
```
The mysql server would be available on `tcp://database:3306`

```

## Q&As

### Q: The build fails with _"ERROR: Insufficient privileges to use privileged mode"_

A: Your repository isn't in the trusted list of repositories. Get in touch with Devops and ask them to trust it.

### Q: The build fails with _"Cannot connect to the Docker daemon. Is the docker daemon running on this host?"_

A: Make sure that your steps contain the environment variable `DOCKER_HOST=tcp://172.17.0.1:2375` like in this case:

```yaml
my-build:
  privileged: true
  image: docker:17.09.0-ce
  environment:
    - DOCKER_HOST=tcp://172.17.0.1:2375
  commands:
    - docker build -t <image_name> .
  when:
    branch: master
    event: push
```

### Q: The build fails when uploading to Quay with the error _"Inappropriate ioctl for device"_

A: This suggests that the `docker` executable prompted for credentials instead of reading them from the command line. This is likely because the secret wasn't injected correctly or the password is incorrect.

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

### Q: Should I use Gitlab with Quay?

A: Please don't. If your repository is hosted in Gitlab then use Artifactory to publish your images. Images published to Artifactory are kept private.

If you still want to use Quay, you should consider hosting your repository on the open (Github).
