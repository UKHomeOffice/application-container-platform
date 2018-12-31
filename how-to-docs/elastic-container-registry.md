# AWS ECR for Private Docker Images

AWS ECR (Elastic Container Registry) is now available as a self-service feature via the Platform Hub. Each project has the capability to create their own Docker Repositories and define individual access to each via the use of IAM Credentials.

## Creating a Docker Repository

Anybody that is part of a Project within the Platform Hub will have the ability to create a new Docker Repository.

1. Login to the Platform Hub via https://hub.acp.homeoffice.gov.uk
1. Navigate to the Projects list: https://hub.acp.homeoffice.gov.uk/projects/list
1. Select your Project from the list to go to the detail page (e.g. https://hub.acp.homeoffice.gov.uk/projects/detail/acp)
    * Ensure you have a **Service** defined within your Project for the Docker Repository to be associated with (check under the `SERVICES` tab)
1. Select the `ALL DOCKER REPOS` tab
1. Select the `REQUEST NEW DOCKER REPO` button
1. Choose the Service to associate this Repository with and provide the name of the Repository to be created (e.g. `hello-world-app`)

The request to create a new Docker Repository can take a few seconds to complete. You can view the status of a Repository by navigating to the `ALL DOCKER REPOS` tab and viewing the list. Once the request has completed, your Repository should have the `Active` label associated with it.

This repository won't automatically refresh, but you can hit the `REFRESH` button above the Repository list or just manually refresh your browser window for updates.

## Generating Access Credentials

Access to ECR Repositories is managed via AWS IAM. These IAM credentials are generated via the Platform Hub and access can be managed per user, per Docker Repository.

1. Navigate to the `ALL DOCKER REPOS` tab for your Project within the Platform Hub
1. For the Repository you have created, select the `MANAGE ACCESS` button
1. At this stage, you can:
    * Create a Robot Account(s), which can be used in deployment pipelines in Drone CI for publishing new images to AWS ECR
    * Select which Project Members have the ability to pull images, and additionally push updates using their own IAM credentials (separate to the Robot Account(s) and CI builds)
1. For this example, select your own User and press `Save`.
    * **Note:** Generally users should never be granted write access, as any write actions should be performed via CI (using the Robot Accounts).
1. Press the `REFRESH` button at the top of the page and check the User Access has a status of `active`

Robot Accounts are visible under the Docker Repository, and once they reveal an `active` status the IAM Credentials are displayed alongside it.

## Accessing a Docker Repository

Accessing the AWS Container Registry to Pull & Push images is currently a two-step process:
1. Use IAM Credentials to generate a temporary authorisation token
1. Use the temporary authorisation token to authenticate your docker client with ECR

> **Note:** The authorisation token generated for docker login is only valid for 12 hours, and so the process above will need to be repeated.

### Pre-Requisites

To follow the below steps you must have:
* AWS CLI (version 1.11.91 or above, check with `aws --version`)
  * Install Guides: [Linux](https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html), [OSX](https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html), [Windows](https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html)
* Docker (version 17.06 or above, check with `docker --version`)

### Step 1: Retrieve an authorisation token

1. Navigate to the `Connected Identities` page: https://hub.acp.homeoffice.gov.uk/identities
1. Under `Amazon ECR` you will have access to your own personal IAM Credentials. These credentials will work across multiple projects whose Repositories you have been granted access to.

With the AWS IAM Credentials retrieved from the `Connected Identities` page, setup a local IAM Profile via the Terminal:
```bash
$ aws configure --profile acp-ecr

AWS Access Key ID [None]: XXXXXXXXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: eu-west-2
Default output format [None]: json

$ export AWS_PROFILE=acp-ecr
```

Now, using the aws-cli you can request an authorisation token to perform a docker login:
```bash
$ aws ecr get-login --no-include-email

docker login -u AWS -p <long-auth-token> https://670930646103.dkr.ecr.eu-west-2.amazonaws.com
```

### Step 2: Login with Authorisation Token

Following a successful `ecr get-login`, a full docker login command should be returned. Copy and paste the command exactly, to login to the ECR endpoint:

```bash
$ docker login -u AWS -p <long-auth-token> https://670930646103.dkr.ecr.eu-west-2.amazonaws.com

WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Login Succeeded
```

> **Note:** If you get an error from Step 1 such as `Unknown options: --no-include-email`, your aws-cli client needs updating. You can omit `--no-include-email` rather than updating your aws-cli client, but the resulting docker login command will include a deprecated `-e none` flag (needs to be removed prior to running the command).


### Pulling & Pushing Images

Within the ACP Kubernetes Clusters, you do not need to provide an `imagePullSecret` as was previously required for images in Artifactory. The ACP Clusters will authenticate behind-the-scenes and be able to successfully pull images from any Docker Repositories you create via the Platform Hub.

The Docker Repositories section of the Platform Hub will provide a URL such as follows for the Repository you have created: `670930646103.dkr.ecr.eu-west-2.amazonaws.com/acp/hello-world-app`

Now that you have locally authenticated with AWS ECR, you can pull and push (if write access was granted) images as normal:

```bash
$ docker build . -t 670930646103.dkr.ecr.eu-west-2.amazonaws.com/acp/hello-world-app:v0.0.1

Sending build context to Docker daemon  32.78MB
...
Successfully built 882e2cadb649
Successfully tagged 670930646103.dkr.ecr.eu-west-2.amazonaws.com/acp/hello-world-app:v0.0.1

$ docker push 670930646103.dkr.ecr.eu-west-2.amazonaws.com/acp/hello-world-app:v0.0.1

The push refers to repository [670930646103.dkr.ecr.eu-west-2.amazonaws.com/acp/hello-world-app]
afbe4b47c182: Pushed
78147c906fce: Pushed
86177d14466d: Pushed
f55514f6bd18: Pushed
ce74984572d7: Pushed
67d7e5db87ee: Pushed
12d012372115: Pushed
b0bb54920d03: Pushed
835c2760f26b: Pushed
e9bcacee1741: Pushed
cd7100a72410: Pushed
v0.0.1: digest: sha256:0309d2655ecef6b4181ee93edfb91f386fc2ebc7849cc88f6e7a18b0d349c35f size: 2628

$ docker pull 670930646103.dkr.ecr.eu-west-2.amazonaws.com/acp/hello-world-app:v0.0.1@sha256:0309d2655ecef6b4181ee93edfb91f386fc2ebc7849cc88f6e7a18b0d349c35f

sha256:0309d2655ecef6b4181ee93edfb91f386fc2ebc7849cc88f6e7a18b0d349c35f: Pulling from acp/hello-world-app
Digest: sha256:0309d2655ecef6b4181ee93edfb91f386fc2ebc7849cc88f6e7a18b0d349c35f
Status: Image is up to date for 670930646103.dkr.ecr.eu-west-2.amazonaws.com/acp/hello-world-app@sha256:0309d2655ecef6b4181ee93edfb91f386fc2ebc7849cc88f6e7a18b0d349c35f
```

## Managing Image Deployments via Drone CI

The Docker Authorisation Token generated via the aws-cli command is only valid for 12 hours, and so this can't be used as a Drone Secret for Docker Image builds. Instead, you would need to store the IAM Credentials for a Robot Account as Drone Secrets and perform the `aws ecr get-login` + `docker login ..` step on each build.

Below is an example Drone CI Pipeline, using the AWS IAM Credentials to retrieve an authorisation token for docker login to ECR:
```yml
pipeline:

  build:
    image: docker:18.09.0
    environment:
    - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
    - docker build -t hello-world-app:$${DRONE_COMMIT_SHA} .

  ecr_push:
    image: docker:18.09.0
    secrets:
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    environment:
    - AWS_DEFAULT_REGION=eu-west-2
    - AWSCLI_IMAGE=quay.io/ukhomeofficedigital/aws-cli:latest
    - DOCKER_HOST=tcp://172.17.0.1:2375
    - REGISTRY_URL=670930646103.dkr.ecr.eu-west-2.amazonaws.com
    commands:
    - authtoken=$(docker run --rm -e "AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=$${AWS_DEFAULT_REGION}" $${AWSCLI_IMAGE} ecr get-login --no-include-email | cut -d' ' -f6)
    - docker login -u AWS -p $authtoken https://$${REGISTRY_URL}
    - docker tag hello-world-app:$${DRONE_COMMIT_SHA} $${REGISTRY_URL}/acp/hello-world-app:$${DRONE_COMMIT_SHA}
    - docker push $${REGISTRY_URL}/acp/hello-world-app:$${DRONE_COMMIT_SHA}
```

**Breakdown of the 4 commands:**
1. Run an aws-cli docker image, using the AWS IAM Credentials from DroneCI Secrets to get an authorisation token. The token is saved to `authtoken` variable, any errors generated from this command are logged to stdout and the Drone Build will fail.
1. Perform a docker login to the registry with the authorisation token, extracted from step 1. The auth token will not be exposed in the build logs via this method.
1. Re-tag the docker image built in the `build` step.
1. Push the docker image to the AWS ECR Repository.
