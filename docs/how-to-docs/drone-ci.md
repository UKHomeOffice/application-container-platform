## Drone CI (v1)

- [Overview](#overview)
- [Repository Migration](#repository-migration)
- [Example Pipelines](#example-pipelines)
- [Services](#services)
  - [Docker-in-Docker](#docker-in-docker)
  - [Anchore Image Scanning](#anchore-image-scanning)
  - [ECR](#ecr)
- [Starlark](#starlark)

### Overview

Drone CI v1 is now available within ACP. For a short time, we will be running both old and new instances to allow projects to migrate each of their own repositories over to the new instances. For reference, the endpoints are:

- [OLD-GITLAB] [https://drone-gitlab.acp.homeoffice.gov.uk](https://drone-gitlab.acp.homeoffice.gov.uk)
- [OLD-GITHUB] [https://drone.acp.homeoffice.gov.uk](https://drone.acp.homeoffice.gov.uk)
- [NEW-GITLAB] [https://drone-gl.acp.homeoffice.gov.uk](https://drone-gl.acp.homeoffice.gov.uk)
- [NEW-GITHUB] [https://drone-gh.acp.homeoffice.gov.uk](https://drone-gh.acp.homeoffice.gov.uk)

**Notable changes:**

- Builds are now Kubernetes Native: Drone CI will create ephemeral Kubernetes Namespaces and Pods for your pipelines, which are torn down entirely after completion. This enables complete isolation of builds and a greater level of security.
- No long-running agents: As with above, there is no longer a requirement for long running agents to run Drone pipeline steps within. This helps keep costs down significantly as the CI environment can run at a lower capacity by default and scale automatically when required.
- Cron Scheduling: Drone CI now supports the use of [cron jobs](https://docs.drone.io/cron/) to execute pipelines on time-based schedules.
- Parallelism: Multiple Pipeline objects can be defined for a single repository and executed in parallel. In addition, build steps can be described as a [directed acyclic graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph), allowing for more complex execution flows.
- Organisation Secrets: Secrets can be created and managed at an Organisation level, i.e. made available to all repositories within your Gitlab group.
- Container Registry Authentication: Pipeline steps referencing images stored in ACP ECR or Artifactory can be pulled by default, without the need to manually authenticate with separate credentials.
- Starlark plugin: define your pipelines by generating a data structure using the [Starlark](https://docs.bazel.build/versions/master/skylark/language.html) language.

### Repository Migration

An initial database migration has occurred from 01/07/2020 to populate the new Drone CI instances with repository secrets, in order to ease the migration process for users. There are required changes to your `.drone.yml` file however, before you are able to activate and execute any new builds.

1. Download and install the latest version of the [drone-cli](https://docs.drone.io/cli/install/) binary.
    It is likely that you will have to interact with the old and the new instances of drone. If that's the case, you might want to rename the `drone` binary you've just downloaded to `drone1` so that you can use the `drone` CLI to interact with the old drone instances (v0.8) and `drone1` to interact with the new ones (v1). Please note that any further reference to `drone` as the CLI refers to the latest version of drone-cli for the v1 instances.
1. Navigate to your repository containing the `.drone.yml` file
1. Use the drone-cli to initially convert to the new format: `drone convert` (run `drone convert --save` after validating the output).
1. For each pipeline definition, specify the `type` to state using the kubernetes build runner (see example below).
1. If your pipeline deals with `deployment` events, replace that event type with `promote`. For example:
1. If any of your steps are running docker builds or leveraging anchore-submission, review the [Services](#Services) section for further updates.
1. De-activate your repository within Drone v0.8 CI: `https://<old-drone-url>/<organisation>/<repository-name>/settings`
1. Activate your repository within Drone v1 CI: `https://<new-drone-url>/<organisation>/<repository-name>/settings`
1. Push your commit to trigger a build (at least the clone step)

Here's an example of setting the runner type as `kubernetes`:

```yml
kind: pipeline
name: default
type: kubernetes
```

And here's how deployments have to be changed to promotions:

from:

```yml
  when:
    event:
    - deployment
```

to:

```yml
  when:
    event:
    - promote
```

Please note that:

1. As the `deployment` event has been replaced by the `promote` and `rollback` events, the `drone` CLI no longer supports `drone deploy`.
    Instead, `drone build promote` has to be used to trigger a `promote` event.
1. If you think you might have to switch to the old pipeline syntax running on the old drone instances during development and testing of your new drone pipeline - for example, if there is a need to apply a fix to a higher environment when your new pipeline is not yet ready, consider specifying a different pipeline file for drone v1.
    In `https://<new-drone-url>/<organisation>/<repository-name>/settings`, you can specify the name of the pipeline file. Drone v0.8 will use `.drone.yml` and for Drone v1, you could specify another file name, e.g. `.drone-v1.yml`. This would allow you to easily and quickly switch between the old and new drone instances and still get the drone servers to use the appropriate pipeline, from the same commit point.
1. Gitlab supports only one webhook to Drone per repository. So, assuming a repo is active on the old drone instance for gitlab, activating it on the new drone instance will get Gitlab to only send events to the new drone instance (even though the repository will still appear to be active on the old drone instance).
    However, Github supports several webhooks. In that case, simply activating a repo on the new drone instance will not prevent the old drone instance to attempt to run the old pipeline. So make sure you deactivate the repo on the old drone instance unless you really want both pipelines to be active at the same time.
1. If a repo is activate on a new Drone instance without its pipeline being modified, it will hang and needs to be cancelled.

### Example Pipelines

For an example of an existing Drone CI Pipeline, please view the [acp-example-app](https://github.com/UKHomeOffice/acp-example-app/blob/master/.drone.yml) repository, which demonstrates the use of:

- Docker image builds (Docker-in-Docker)
- Leveraging Secrets
- Scanning via Anchore
- Pushing an image to Artifactory
- Pushing an image to ECR

Additionally, the [kube-example-app](https://github.com/UKHomeOffice/kube-example-app/blob/master/.drone.yml) repository provides an example on the use of build promotion (replacing drone deployment events).

More Kubernetes pipeline examples are available here: https://docs.drone.io/pipeline/kubernetes/examples/

### Services

Drone CI supports launching [dedicated service containers](https://docs.drone.io/pipeline/kubernetes/syntax/services) as part of your pipeline. Typical use cases for this may be when your unit tests may require a database to validate against, or performing docker-in-docker functions (image builds). The official documentation covers many [service examples](https://docs.drone.io/pipeline/kubernetes/examples) which you can leverage in your build pipelines.

**Note:**

- Privileged Pipeline Steps are not permitted on ACP Drone CI. There should not be any reason to mark your repository as privileged, as the official Drone Plugin and DIND images are made privileged by default (when the entrypoint is not overridden). If you run into problems with this, please contact the ACP Team.
- Services are started immediately on initial pipeline execution. After a service is started, the software running inside the container may take time to initialise and begin accepting connections. Be sure to account for this in your step execution (e.g. via a sleep command or polling for the service endpoint to be available). This is why the docker build steps below either sleep or wait for the `docker.sock` file to be present before starting the build. See [Services](https://docs.drone.io/pipeline/kubernetes/syntax/services/) for more information.

#### Docker-in-Docker

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
  # wait for docker service to be up before running docker build
  - n=0; while [ "$n" -lt 60 ] && [ ! -e /var/run/docker.sock ]; do n=$(( n + 1 )); sleep 1; done
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
  # wait for docker service to be up before running docker build
  - sleep 5
  - docker build -t test .

services:
- name: docker
  image: docker:dind
  environment:
    DOCKER_TLS_CERTDIR: ""
```

#### Anchore Image Scanning

As with above, an anchore-submission server sidecar was previously run in the Docker Agent pods to enable image scanning. This can now be achieved by running an anchore-submission-server service, as follows:

```yml
kind: pipeline
type: kubernetes
name: default

steps:
- name: build-image
  image: docker:dind
  commands:
  # wait for docker service to be up before running docker build
  - n=0; while [ "$n" -lt 60 ] && [ ! -e /var/run/docker.sock ]; do n=$(( n + 1 )); sleep 1; done
  - docker build -t test:$${DRONE_COMMIT_SHA} .
  volumes:
  - name: dockersock
    path: /var/run

- name: scan-image
  image: docker.digital.homeoffice.gov.uk/acp-anchore-submission:latest
  environment:
    IMAGE_NAME: test:${DRONE_COMMIT_SHA}
    SERVICE_URL: http://anchore-submission-server:10080

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

#### ECR

##### Pushing an image to ECR

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

##### Building from a base image in ECR

If you are building from a docker base image in ECR (`FROM 340268328991.dkr.ecr.eu-west-2.amazonaws.com/my-project/my-base-image:image-version`), then you need to authenticate with ECR before being able to pull from it:

``` yml
---
kind: pipeline
name: default
type: kubernetes

platform:
  os: linux
  arch: amd64

steps:
- name: ecr-login
  pull: if-not-exists
  image: quay.io/ukhomeofficedigital/dind-awscli:19.03.12-dind-1.18.55
  environment:
    AWS_ACCESS_KEY_ID:
      from_secret: ecr_aws_access_key_id
    AWS_SECRET_ACCESS_KEY:
      from_secret: ecr_aws_secret_access_key
    AWS_REGION: eu-west-2
  commands:
  # wait for docker service to be up before running docker build
  - n=0; while [ "$n" -lt 60 ] && [ ! -e /var/run/docker.sock ]; do n=$(( n + 1 )); sleep 1; done
  - aws ecr get-login-password --region $${AWS_REGION} | docker login --username AWS --password-stdin 340268328991.dkr.ecr.$${AWS_REGION}.amazonaws.com
  volumes:
  - name: dockersock
    path: /var/run
  - name: dockerclientconfig
    path: /root/.docker
  when:
    event:
    - push
    - tag

- name: build
  pull: if-not-exists
  image: docker:19.03.12-dind
  environment:
    AWS_REGION: eu-west-2
  commands:
  - docker build -t 340268328991.dkr.ecr.eu-west-2.amazonaws.com/my-project/my-image:$${DRONE_COMMIT_SHA} . --no-cache
  volumes:
  - name: dockersock
    path: /var/run
  - name: dockerclientconfig
    path: /root/.docker
  when:
    event:
    - push
    - tag

# additional steps: do image scanning and image pushing as required

services:
- name: docker
  image: docker:19.03.12-dind
  volumes:
  - name: dockersock
    path: /var/run

volumes:
- name: dockersock
  temp: {}
- name: dockerclientconfig
  temp: {}

...

```

### Starlark

TL;DR Drone pipelines can be defined using the Starlark language. A `main` function is responsible for returning a data structure in a format compatible with the `.drone.yml` file.

The Starlark plugin has been deployed alongside the Drone server.

This means that instead of defining Drone pipelines in static yaml files, the [Starlark](https://docs.bazel.build/versions/master/skylark/language.html) language can be used to describe the pipeline. For more details, here is the [language specification](https://github.com/google/starlark-go/blob/master/doc/spec.md).

Using code to define pipelines allows them to be [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

So, for example, it is now possible to:

- define constants in a single place and use them in several pipelines or steps
- define parameterised steps and instantiate them in the same or different pipelines

Here's a very basic example of a `.drone.star` file:

``` python
def main(ctx):
  return {
    "name": "build",
    "kind": "pipeline",
    "type": "kubernetes",
    "steps": [
      {
        "name": "build",
        "image": "alpine",
        "commands": [
            "echo hello world"
        ]
      }
    ]
  }
```

A more complex example keeping the pipeline DRY can be found in the acp-example-app's [.drone.star](https://github.com/UKHomeOffice/acp-example-app/blob/master/.drone.star) file.

Using Starlark is a good option for complex pipelines where a lot of repetition is required, but it might be considered over the top for simpler pipelines.

You can test your `.drone.star` file locally by running:

``` sh
drone starlark --stdout
```

and if you want test what is generated for example when a tag is pushed, you can run:

``` sh
drone starlark --stdout --build.event tag
```

More options are available:

``` sh
drone starlark -h

NAME:
   drone starlark - generate .drone.yml from starlark

USAGE:
   drone starlark [command options] [path/to/.drone.star]

OPTIONS:
   --source value          Source file (default: ".drone.star")
   --target value          target file (default: ".drone.yml")
   --format                Write output as formatted YAML
   --stdout                Write output to stdout
   --repo.name value       repository name
   --repo.namespace value  repository namespace
   --repo.slug value       repository slug
   --build.event value     build event (default: "push")
   --build.branch value    build branch (default: "master")
   --build.source value    build source branch (default: "master")
   --build.target value    build target branch (default: "master")
   --build.ref value       build ref (default: "refs/heads/master")
   --build.commit value    build commit sha
   --build.message value   build commit message
```
