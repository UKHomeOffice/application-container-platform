# Drone CI

- [Drone CI](#drone-ci)
  - [Overview](#overview)
  - [Repository Migration](#repository-migration)
  - [Example Pipelines](#example-pipelines)
  - [Services](#services)
    - [Docker-in-Docker](#docker-in-docker)
    - [Anchore Image Scanning](#anchore-image-scanning)
    - [ECR](#ecr)

## Overview

Drone CI v1 is now available within ACP. For a short time, we will be running both old and new instances to allow projects to migrate each of their own repositories over to the new instances. For reference, the endpoints are:
- [OLD-GITLAB] https://drone-gitlab.acp.homeoffice.gov.uk
- [OLD-GITHUB] https://drone.acp.homeoffice.gov.uk
- [NEW-GITLAB] https://drone-gl.acp.homeoffice.gov.uk
- [NEW-GITHUB] https://drone-gh.acp.homeoffice.gov.uk

**Notable changes:**
- Builds are now Kubernetes Native: Drone CI will create ephemeral Kubernetes Namespaces and Pods for your pipelines, which are torn down entirely after completion. This enables complete isolation of builds and a greater level of security.
- No long-running agents: As with above, there is no longer a requirement for long running agents to run Drone pipeline steps within. This helps keep costs down significantly as the CI environment can run at a lower capacity by default and scale automatically when required.
- Cron Scheduling: Drone CI now supports the use of [cron jobs](https://docs.drone.io/cron/) to execute pipelines on time-based schedules.
- Parallelism: Multiple Pipeline objects can be defined for a single repository and executed in parallel. In addition, build steps can be described as a [directed acyclic graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph), allowing for more complex execution flows.
- Organisation Secrets: Secrets can be created and managed at an Organisation level, i.e. made available to all repositories within your Gitlab group.
- Container Registry Authentication: Pipeline steps referencing images stored in ACP ECR or Artifactory can be pulled by default, without the need to manually authenticate with separate credentials.

## Repository Migration

An initial database migration has occurred from 01/07/2020 to populate the new Drone CI instances with repository build logs and secrets, in order to ease the migration process for users. There are required changes to your `.drone.yml` file however, before you are able to activate and execute any new builds.

1. Download and install the latest version of the [drone-cli](https://docs.drone.io/cli/install/) binary.
1. Navigate to your repository containing the `.drone.yml` file
1. Use the drone-cli to initially convert to the new format: `drone convert` (add `--save` argument after validating the output).
1. For each pipeline definition, specify the `type` to state using the kubernetes build runner. For example:
    ```yml
    kind: pipeline
    name: default
    type: kubernetes
    ```
1. If any of your steps are running docker builds or leveraging anchore-submission, review the [Services](#Services) section for further updates.
1. Activate your repository within Drone CI: `https://<drone-url>/<organisation>/<repository-name>/settings`

## Example Pipelines

For an example of an existing Drone CI Pipeline, please view the [acp-example-app](https://github.com/UKHomeOffice/acp-example-app/blob/master/.drone.yml) repository, which demonstrates the use of:
- Docker image builds (Docker-in-Docker)
- Leveraging Secrets
- Scanning via Anchore
- Pushing an image to Artifactory
- Pushing an image to ECR

Additionally, the [kube-example-app](https://github.com/UKHomeOffice/kube-example-app/blob/master/.drone.yml) repository provides an example on the use of deployments (build promotion).

More Kubernetes pipeline examples are available here: https://docs.drone.io/pipeline/kubernetes/examples/

## Services

Drone CI supports launching [dedicated service containers](https://docs.drone.io/pipeline/kubernetes/syntax/services) as part of your pipeline. Typical use cases for this may be when your unit tests may require a database to validate against, or performing docker-in-docker functions (image builds). The official documentation covers many [service examples](https://docs.drone.io/pipeline/kubernetes/examples) which you can leverage in your build pipelines.

**Note:**
- Privileged Pipeline Steps are not permitted on ACP Drone CI. There should not be any reason to mark your repository as privileged, as the official Drone Plugin and DIND images are made privileged by default (when the entrypoint is not overridden). If you run into problems with this, please contact the ACP Team.
- Services are started immediately on initial pipeline execution. After a service is started, the software running inside the container may take time to initialise and begin accepting connections. Be sure to account for this in your step execution (e.g. via a sleep command or polling for the service endpoint to be available).

### Docker-in-Docker

Previously with ACP Drone CI v0.8 we ran a sidecar container running a docker daemon to provide DIND, which is why you had to specify the environment variable `DOCKER_HOST=tcp://172.17.0.1:2375`.

With Drone CI v1 you would now define your own DIND Service to run within your pipeline step, for example:

```yml
kind: pipeline
type: kubernetes
name: default

steps:
- name: build-image
  image: docker:dind
  commands:
  - docker build -t test .
  volumes:
  - name: dockersock
    path: /var/run

services:
- name: docker
  image: docker:dind
  volumes:
  - name: dockersock
    path: /var/run

volumes:
- name: dockersock
  temp: {}
```

Alternatively, the same can be achieved without the need to share volumes and the docker socket file. Services within a pipeline can be accessed from any step, via a hostname of which the value is identical to the name of the service. For example, the above docker build can also be achieved as follows:

```yml
kind: pipeline
type: kubernetes
name: default

steps:
- name: build-image
  image: docker:dind
  environment:
    DOCKER_HOST: tcp://docker:2375
  commands:
  - docker build -t test .

services:
- name: docker
  image: docker:dind
  environment:
    DOCKER_TLS_CERTDIR: ""
```

### Anchore Image Scanning

As with above, an anchore-submission server sidecar was previously run in the Docker Agent pods to enable image scanning. This can now be achieved by running an anchore-submission-server service, as follows:

```yml
kind: pipeline
type: kubernetes
name: default

steps:
- name: build-image
  image: docker:dind
  commands:
  - docker build -t test:$${DRONE_COMMIT_SHA} .
  volumes:
  - name: dockersock
    path: /var/run

- name: scan-image
  image: docker.digital.homeoffice.gov.uk/acp-anchore-submission:latest
  environment:
    IMAGE_NAME: test:${DRONE_COMMIT_SHA}
    SERVICE_URL: http://anchore-submission-server:10080
  volumes:
  - name: dockersock
    path: /var/run

services:
- name: docker
  image: docker:dind
  volumes:
  - name: dockersock
    path: /var/run

- name: anchore-submission-server
  image: docker.digital.homeoffice.gov.uk/acp-anchore-submission:latest
  commands:
    - /anchore-submission server
  environment:
    ANCHORE_URL: "acp-anchore.acp.homeoffice.gov.uk"
    REGISTRY_URL: "acp-ephemeral-registry.acp.homeoffice.gov.uk"
  volumes:
  - name: dockersock
    path: /var/run

volumes:
- name: dockersock
  temp: {}
```

### ECR

Drone CI has an [official ECR plugin](http://plugins.drone.io/drone-plugins/drone-ecr/), which can be used for both the build and push of a Docker image in a single step.

```yml
kind: pipeline
type: kubernetes
name: default

steps:
- name: publish
  image: plugins/ecr
  environment:
    AWS_REGION: eu-west-2
  settings:
    access_key:
      from_secret: aws_access_key_id
    secret_key:
      from_secret: aws_secret_access_key
    repo: <ecr-repo-name>
    registry: 340268328991.dkr.ecr.eu-west-2.amazonaws.com
```
