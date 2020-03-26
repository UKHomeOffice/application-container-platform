## Writing Dockerfiles

#### Dockerfile best practice
We recommend familiarising yourself with Docker's excellent [guidance](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices) on this topic.   

It is often easier to build from an existing base image. To find such base images that are maintained by Home Office colleagues, you can search the [UKHomeOffice organisation](https://github.com/UKHomeOffice) on Github for repos starting with ‘docker-’ - e.g.: [docker-java11-mvn](https://github.com/UKHomeOffice/docker-java11-mvn)

If you want to use a base image in the UKHomeOffice organisation that does not appear to be regularly maintained, please get in touch via the ACP Service Desk and we will arrange write access to that repo.

Please make sure that any base image that you maintain adheres to the best practices set out by Docker, and includes instructions to update all existing packages - e.g.:
```
yum install -y curl && yum clean all && rpm --rebuilddb
```

#### Home Office CentOS base image
If none of the technology specific images work for you, you can either build on top of them or build from the base [Centos image](https://github.com/UKHomeOffice/docker-centos-base).
