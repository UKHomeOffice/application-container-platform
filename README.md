* [Application Container Platform](#application-container-platform)
   * [Benefits of using ACP](#benefits-of-using-acp)
   * [Must Read](#must-read)
   * [Service Status](#service-status)
   * [Accessing the Services](#accessing-the-services)
   * [Support](#support)
   * [How-to-docs](#how-to-docs)
   * [Services](#services)
      * [VPN](#vpn)
      * [Source Code Management](#source-code-management)
         * [GitHub](#github)
         * [GitLab](#gitlab)
      * [CI](#ci)
         * [Drone](#drone)
         * [Jenkins](#jenkins)
      * [Binary / Artifact Storage](#binary--artifact-storage)
         * [Quay](#quay)
         * [ECR](#ecr)
         * [Artifactory](#artifactory)
      * [Domain Name System (DNS) Pattern](#domain-name-system-dns-pattern)
         * [For Non-production Services](#for-non-production-services)
         * [For Production Services](#for-production-services)
      * [Application Composition](#application-composition)
         * [Keycloak Gatekeeper](#keycloak-gatekeeper)
         * [Nginx Proxy](#nginx-proxy)
         * [cfssl Sidekick](#cfssl-sidekick)
      * [Logging](#logging)
         * [Current Log Retention Policy](#current-log-retention-policy)
      * [Metrics / Monitoring](#metrics--monitoring)
         * [Sysdig](#sysdig)
         * [Sysdig training](#sysdig-training)
      * [Security and disaster recovery](#security-and-disaster-recovery)
      * [Reusable components](#reusable-components)
         * [Terraform modules](#terraform-modules)
         * [Base docker images](#base-docker-images)

# Application Container Platform

This page will give you an overview of ACP, the services it entails and the ways to get access to them. This is a general overview. Developers should check out the [Developer Docs](https://github.com/UKHomeOffice/application-container-platform/tree/master/developer-docs).

The Application Container Platform provides an accredited, secure, scalable, reliable and performant hosting platform for Home Office applications.​

We use open source technology to allow delivery teams to develop, build, deploy and manage applications in a trusted environment. ​

We focus on enabling self-service where possible, and have developed a Platform Hub to act as a one stop shop for all things ACP, including support requests for things that aren't self serve (yet).

## Benefits of using ACP

* Reliance on specialist DevOps resource significantly reduced​
* Central place to host applications​
* Saves time for the projects​
* Significant hosting cost reduction​
* Common tools and patterns across projects i.e. CI​

---
## Must Read
Everyone using our platform **MUST** adhere to [technical service standards](https://github.com/UKHomeOffice/technical-service-requirements/blob/master/docs/ci.md).
All Services will be under a review process.

---

## Service Status

For an overview of the platform services we provide and their current status i.e. Alpha, Beta, Live; please refer to the [platform service status page](docs/platform_service_status.md). This is to give consumers of the platform a single reference point on the services we are providing and where each service is in the lifecycle. For definitions on each phase of the lifecycle and the criteria for production-ready, please refer [here](docs/service_lifecycle.md).

## Accessing the Services
When trying to get onto the platform for the first time you will need to get access to a various things that will allow you to get to other things. The full flow for this can be found [here](docs/newuser.md)

## Support
[You can find more information about support here](sla.md)
If you require support you can talk to us on our Slack Channel or raise an issue on our [BAU Board](https://github.com/UKHomeOffice/application-container-platform-bau).

## How-to-docs
We have a bunch of handy how-to guides located in this repository, find the list of them [here](how-to-docs/README.md)

## Services
These are the core services which we provide across our platform.

### VPN
Many of our services are behind a VPN (using [OpenVPN](https://wiki.archlinux.org/index.php/OpenVPN) protocol) for security reasons. We have many different roles and profiles for accessing different environments. These profiles are all found at [Access ACP](https://access-acp.digital.homeoffice.gov.uk).
You can download VPN profiles for the environments you have access to. New profiles can be set up to connect through to things like project specific AWS accounts.
Each profile will expire after a certain amount of time (2-12 hours), users will have to download a new profile once their certificates which are baked into the openvpn profiles expire.

### Source Code Management
#### GitHub
GitHub is where we store our open source code. You need to be added to the Uk HomeOffice organisation to access most of our code. More documentation can be found [here](https://help.github.com/)

#### GitLab
[GitLab](https://gitlab.digital.homeoffice.gov.uk) is where we store our more private code. Hosted in our ops cluster, you will need an office 365 account to get in via single sign on. Each project has its own group which are managed by members of that project. More in depth guides to gitlab can be found [here](https://docs.gitlab.com/ce/README.html).

### CI
#### Drone
Drone is our CI tool for building and deploying applications. We have two instances, one for [GitLab](https://drone-gitlab.acp.homeoffice.gov.uk) and one for [GitHub](https://drone.acp.homeoffice.gov.uk). More instructions can be found [here](../how-to-docs/drone-how-to.md).

#### Jenkins
Jenkins is considered a legacy system and is not supported.

### Binary / Artifact Storage
#### Quay
[Quay](https://quay.io/ukhomeofficedigital) is where store all of our open source container images.

#### ECR
We use AWS ECR to host our private container images for high availability and resiliency. For more information on how to use ECR see [here](../how-to-docs/drone-how-to.md)

#### Artifactory
We use [Artifactory](https://artifactory.digital.homeoffice.gov.uk) as our internal binary repository store, projects can push build artifacts / dependencies here. Prior to the introduction of ECR, docker images were also push here, and can be access via https://docker.digital.homeoffice.gov.uk, log in via the Office 365 button to view your artifacts.

### Domain Name System (DNS) Pattern
To standardise on how services route their application traffic to the appropriate hosting platform and to offer consistency in how we approach DNS we have a standard DNS naming convention for services.

In parallel to this, users need to also be aware of [the limits on certificates and letsencrypt](../how-to-docs/certificates.md) if they are wanting external TLS certificates for their services.

#### For Non-production Services
The following categories are something we would expect a service to specify:

`Service Name` - The name of the service users or other services will attempt to consume i.e. `web-portal`

`Env` - The environment of the service i.e. `Dev`

`Service` - The overall service name or project name i.e. `example-service`

```
<servicename>.<env>.<service>-notprod.homeoffice.gov.uk

web-portal.dev.example-service-notprod.homeoffice.gov.uk
```

#### For Production Services
As we want to protect production services from hitting limits and to create a distinction between services that are non-production, (not prod)  and production, we simplify the overall approach by using the main service name as the domain.

`Service Name` - The name of the service users or other services will attempt to consume i.e. `web-portal`

`Service` - The overall service name or project name i.e. `example-service`

```
<servicename>.<service>.homeoffice.gov.uk

web-portal.example-service.homeoffice.gov.uk
```

### Application Composition
The following are containers that we create for use alongside your own application

#### Keycloak Gatekeeper
[Keycloak Proxy](https://github.com/keycloak/keycloak-gatekeeper): a container for putting auth in front of your application.
#### Nginx Proxy
[Nginx Proxy](https://github.com/UKHomeOffice/docker-nginx-proxy): for TLS and proxying your application container.
#### cfssl Sidekick
[cfssl-sidecar](https://github.com/UKHomeOffice/cfssl-sidekick): for providing a server TLS cert on demand from a cluster hosted cfssl server.

### Logging
Logging stack consists of [Elasticsearch](https://github.com/UKHomeOffice/docker-elasticsearch), [Logstash](https://github.com/UKHomeOffice/docker-logstash-kubernetes), [Kibana](https://github.com/UKHomeOffice/docker-kibana)).

- Logstash agents deployed as a daemonSet will collect all workload logs and index them in Elasticsearch.
- Logs are searchable for a period of 5 days through [Kibana UI](https://kibana.acp.homeoffice.gov.uk). Access to view logs can be requested via [Support request](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/kibana-access-request).

#### Current Log Retention Policy
- Logs are searchable in Kibana for 5 days and remain within Elasticsearch for 10 days.
- Collected workload logs will be persisted in S3 indefinitely and migrated to the infrequent access storage class and then glacier storage after 60 and 180 days respectively. **NOTE: this may change in the future!**
- The same policy applies to all logs within ELK

### Metrics / Monitoring
#### Sysdig
[Sysdig](https://sysdig.digital.homeoffice.gov.uk) is our metric collection tool. We are working closely with Sysdig on the development of this. It can be used for dashboards, alerting and much more. More information can be found on the [Sysdig Monitor site](https://sysdig.com) and for the open-source tool, [Sysdig](http://sysdig.org) (command line tool) and [Sysdig Inspect](https://github.com/draios/sysdig-inspect).

#### Sysdig training
Sysdig have an online training course which covers the basics of using the product, [Sysdig 101](https://sysdig.teachable.com/). Sysdig recommends new users complete this training.

### Security and disaster recovery

The Application Container Platform employs robust security principles, including but not limited to:

- encryption of data at rest and in transit
- restricting access to resources according to operational needs
- strict authorisation requirements for all endpoints
- [role based access control](docs/rbac.md)

The Platform is spread across multiple availability zones, which are essentially three different data centres within a region. In case of an entire AWS region going down for a prolonged period of time, the Platform can be recreated in another region within a few hours.

The recovery of products hosted on the Platform are subject to considerations set out for the Production Ready criteria in [Service Lifecycle](docs/service_lifecycle.md).

For further information on security and disaster recovery considerations, please raise a ticket on the [BAU Board](https://github.com/UKHomeOffice/application-container-platform-bau/issues).


### Reusable components
Whilst building ACP, we've written a things that other projects may be interested in reusing. These can be found on GitHub here
#### Terraform modules
https://github.com/UKHomeOffice?utf8=%E2%9C%93&q=acp-tf&type=&language=
#### Base docker images
https://github.com/UKHomeOffice?utf8=%E2%9C%93&q=docker-&type=&language=
