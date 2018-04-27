# Drone snippets

## Basic pipeline with automatic deploy to dev

```yaml
pipeline:

  build:
    image: docker:18.03
    environment:
      - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
      - docker build -t <image_name>:$${DRONE_COMMIT_SHA} .
    when:
      event: push

  image_to_quay:
    image: ukhomeoffice/drone-docker
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

  tagged_image_to_quay:
    image: ukhomeoffice/drone-docker
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

  clone_deployment_scripts:
    image: plugins/git
    secrets:
      - github_token
    commands:
      - git clone https://$${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo_name>.git kube
    when:
      branch: master
      event: push

  deploy_to_dev:
    image: quay.io/ukhomeofficedigital/kd:v0.13.0
    environment:
      - KUBE_NAMESPACE=<your_namespace>
    secrets:
      - kube_server
      - kube_token
    commands:
      - cd kube
      - git checkout v1.0.0
      - ./deploy.sh
    when:
      branch: master
      event: push
```

## Promotion to production

```yaml
pipeline:

  clone_deployment_scripts:
    image: plugins/git
    commands:
      - git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo_name>.git kube
    when:
      event: deployment

  deploy_to_prod:
    image: quay.io/ukhomeofficedigital/kd:v0.13.0
    environment:
      - KUBE_NAMESPACE=<dev-induction>
    secrets:
      - kube_server
      - kube_token
    commands:
      - cd kube
      - git checkout v1.1
      - ./deploy.sh
    when:
      environment: prod
      event: deployment
```

## PR Builder

```yaml
pipeline:

  pr-builder:
    image: docker:18.03
    environment:
      - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
      - docker build -t <image_name> .
    when:
      event: pull_request
```

## Export Drone variables automatically

Add these lines to your `.bashrc` file:

```bash
export DRONE_SERVER=https://drone.acp.homeoffice.gov.uk # change if you need it for gitlab
export DRONE_TOKEN=<your_drone_token>
```

or add it as a function so you can swap between Github and Gitlab as needed:

```bash
function dronehub {
  export DRONE_SERVER=https://drone.acp.homeoffice.gov.uk
  export DRONE_TOKEN=<your_github_drone_token>
}

function dronelab {
  export DRONE_SERVER=https://drone-gitlab.acp.homeoffice.gov.uk
  export DRONE_TOKEN=<your_gitlab_drone_token>
}
```

## SonarQube

[SonarQube](https://sonarqube.digital.homeoffice.gov.uk/) is an open source quality management platform, dedicated to continuously analyze and measure source code quality. You can post code coverage and reports to SonarQube using plugins for languages such as [Scala](https://github.com/Sagacify/sonar-scala) and [Javascript](https://github.com/skhatri/grunt-sonar-runner).

You can enable SonarQube in Drone with the [docker-sonar-scanner](https://github.com/UKHomeOffice/docker-sonar-scanner) plugin.

Add this step to your pipeline to enable it:

```yaml
pipeline:

  sonar-scanner:
    image: quay.io/ukhomeofficedigital/sonar-scanner:v0.0.2
    when:
      event: push
      branch: master
```

Create a file `sonar-project.properties` in the root of your project with the following content:

```
# Name of your git repo
sonar.projectKey=<your_repo>
# Name of your git repo
sonar.projectName=<your_repo>
# Language
sonar.language=<language>
# Location of your src
sonar.sources=app
# Location of your tests
sonar.tests=test
# Location of your code coverage reports
#sonar.scoverage.reportPath=
```
