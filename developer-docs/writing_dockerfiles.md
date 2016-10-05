# Home Office Dockerfile best practice

## Dockerfile best practice
We recommend using dockers excellent guidance for this!  
https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

## Docker images to build from
This document lists all of our docker base images that you can build from:

### Technology specific images

* [NodeJS onbuild image - recommended by default](https://github.com/UKHomeOffice/docker-nodejs)
* [NodeJS base image - if you need more flexibility](https://github.com/UKHomeOffice/docker-nodejs-base)
* [Scala image](https://github.com/UKHomeOffice/docker-scala-sbt)

### Home Office CentOS base image
If none of the technology specific images work for you you can either build on top of them or build from the base centos image:  
https://github.com/UKHomeOffice/docker-centos-base

If you build an image that will be of use to other teams then please add it to the list of technology specific images above!
