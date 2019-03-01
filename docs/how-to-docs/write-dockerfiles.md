## Writing Dockerfiles

#### Dockerfile best practice
We recommend using dockers excellent guidance for this!  
https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

#### Docker images to build from
This document lists all of our docker base images that you can build from:

#### Technology specific images

* [NodeJS onbuild image - recommended by default](https://github.com/UKHomeOffice/docker-nodejs)
* [NodeJS base image - if you need more flexibility](https://github.com/UKHomeOffice/docker-nodejs-base)
* [Scala image](https://github.com/UKHomeOffice/docker-scala-sbt)
* [JDK image](https://github.com/UKHomeOffice/docker-openjdk8)
* [Maven image with Java 8](https://github.com/UKHomeOffice/docker-java8-mvn)
* [Ruby image](https://github.com/UKHomeOffice/docker-ruby)

#### Home Office CentOS base image
If none of the technology specific images work for you you can either build on top of them or build from the base centos image:  
https://github.com/UKHomeOffice/docker-centos-base

If you build an image that will be of use to other teams then please add it to the list of technology specific images above! And please make sure it adheres to the below guidance on building new base images.

#### Guidance on building new base images
All base images should be built with a set of onbuild commands in them to make sure anything built on top of them will automatically update the base OS, for example:
```
yum install -y curl && yum clean all && rpm --rebuilddb
```
The [nodejs base image](https://github.com/UKHomeOffice/docker-nodejs-base/blob/master/Dockerfile) is a good example of this.
