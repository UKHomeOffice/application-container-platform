# Drone snippets

## Basic pipeline with automatic deploy to dev

```yaml
pipeline:

  build:
    privileged: true
    image: docker:1.11
    environment:
      - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
      - docker build -t quay.io/ukhomeofficedigital/<image_name>:$${DRONE_COMMIT_SHA} .
    when:
      branch: master
      event: push
      
  image_to_quay:
    image: docker:1.11
    environment:
      - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
      - docker login -u="ukhomeofficedigital+<your_robot_username>" -p=$${DOCKER_PASSWORD} quay.io
      - docker push quay.io/ukhomeofficedigital/<your_quay_repo>:$${DRONE_COMMIT_SHA} .
    when:
      branch: master
      event: push
      
  clone_deployment_scripts:
    image: plugins/git
    commands:
      - git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/UKHomeOffice/<your_repo_name>.git kube
    when:
      branch: master
      event: push
      
  deploy_to_dev:
    image: quay.io/ukhomeofficedigital/kd:v0.2.2
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
      environment: master
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
    image: quay.io/ukhomeofficedigital/kd:v0.2.2
    environment:
      - KUBE_NAMESPACE=dev-induction
    secrets:
      - kube_server
      - kube_token
    commands:
      - cd kube
      - git checkout v1.1
      - ./deploy.sh
    when:
      environment: production
      event: deployment
```

## PR Builder

```yaml
pipeline:

  pr-builder:
    privileged: true
    image: docker:1.11
    environment:
      - DOCKER_HOST=tcp://172.17.0.1:2375
    commands:
      - docker build -t <image_name> .
    when:
      event: pull_request
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
