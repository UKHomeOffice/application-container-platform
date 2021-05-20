# Services

ACP (Application Container Platform) is a series of services which Home Office developers should use to develop and host Home Office applications. This page provides an overview of how ACP uses each service.

To use ACP, you require knowledge of the following services:

  * Docker: a software tool designer that allows you to create, deploy and run applications using containers
  * Kubernetes: an open-source platform for automating deployment, scaling, and operation of application containers across clusters of hosts
  * GitHub and GitLab: repositories which store open-source and private code respectively
  * Drone: a CI (Continuous Integration) tool for building and deploying applications
  * Quay: an open-source container repository
  * Amazon Elastic Container Registry (ECR): a container registry for storing, managing, and deploying private Docker container images
  * Artifactory: an internal repository to store artefacts (including binaries and dependencies)
  * Keycloak: an open-source identity and access-management tool
  * Sysdig: an alert monitoring tool for containers, Kubernetes and cloud-based services

Where a service requires a bespoke or custom configuration to use ACP, we will provide details of the prerequisites. For example, for instructions on how to set up your services for the ACP induction, see [Developer Onboarding][dev_onboarding].

Any other information on individual services is outside the scope of our documentation. For information on how to achieve configurations on the service side, we recommend referring to the service vendor’s documentation.    



## VPN


For security reasons, most ACP services run behind a VPN using the OpenVPN protocol.

Download VPN Profiles from [ACP VPN][acp_vpn]. The kube-platform profile provides you with access to ACP services. If you also need access to the production environment, raise a request on [ACP Support][support].

Note that in addition to a VPN profile, some environments require access rights. Contact your project administrator for more information.

kube-platform profiles expire after 72 hours, after which you must download a new kube-platform profile to continue accessing ACP services.



## Source Code Management

### GitHub

ACP's open-source code repository is on GitHub, in the [UKHomeOffice organisation][ho_repo].

For more information on GitHub, see the [GitHub documentation][github_docs].

### GitLab

ACP’s private code repository is on GitLab, which we host on our ops cluster. To access it you need an Office 365 account with single sign-on capabilities. To request an Office 365 account (licensed or AD-user), please search [ITNow][itnow] on POISE for 'digital tenant requests'. ACP cannot request an account on your behalf.

Each project has its own group and manager(s). To authenticate, use SSH on TCP port 2222.

For more information on GitLab, see the [GitLab documentation][gitlab_docs].



## CI

### Drone

ACP uses Drone as its CI tool for building and deploying applications. There are two ACP instances of Drone: one for [GitHub][drone_gh] and one for [GitLab][drone_gl].

For more information on using Drone with ACP, see [Drone CI][drone_ci].

For more information on Drone, see the [Drone documentation][drone_docs].



## Container Storage

ACP recommends having separate registries for open-source and private container images:

  * if your code is open-source and hosted on GitHub, use Quay to store container images
  * if your code is private and hosted on GitLab, use Amazon ECR

For more information on Quay, see the [Quay][quay_docs].

For more information on ECR, see the [Amazon ECR documentation][ecr_docs].



## Artefact Storage

### Artifactory

ACP uses [Artifactory][artifactory] as its internal binary store for projects to push build time artefacts and dependencies to, such as jars and python modules.  

Before ACP began using Amazon ECR, we also stored Docker images on Artifactory. You can now access those images [here][docker_images]. Note that if an image is not downloaded for one year, we remove it from the repository.

For more information on Artifactory, see the [JFrog Artifactory documentation][artifactory_docs].



## Application Composition

Applications hosted on ACP typically use the following containers:

  * [Keycloak Gatekeeper][gatekeeper]: protects applications using [Keycloak][keycloak]. Note that in the future Red Hat is going to deprecate support and ACP will use an alternative.
  * [Nginx Proxy][nginx]: provides TLS and proxying for your application container
  * [Cert-Manager][cert_mgr]: obtains internal and external certificates

For an example ACP application with deployment files, see [acp-example-app][acp_example] and [kube-example-app][kube_example].



## Logging

ACP’s logging stack consists of [Elasticsearch][elasticsearch], [Fluentd][fluentd], and [Kibana][kibana], also known as EFK:

  * ACP deploys Fluentd agents as a daemonSet, which collect all workload logs and indexes them in Elasticsearch.
  * you can search for logs on [ACP's Kibana instance][acp_kibana]. To access Kibana for your namespace, raise [this support request][support_kibana] on ACP Support.

### Log Retention Policy

The following applies both to workload logs and all logs within EFK:

  * logs remain searchable in Kibana for 5 days and within Elasticsearch for 10 days.
  * ACP persists workload logs it collects in S3 indefinitely  
  * after 60 days, ACP migrates logs in S3 to the infrequent access storage class and then glacier storage  
  * after 180 days, ACP migrates logs in S3 to glacier storage



## Monitoring and Metrics

### Sysdig

ACP uses Sysdig for container monitoring and metric collection. Sysdig provides these through alert monitoring and metric dashboards for your Kubernetes infrastructure. You can access our instance [here][acp_sysdig].

For more information on Sysdig, see the [Sysdig documentation][sysdig_docs].



## Security and Disaster Recovery

ACP employs robust security principles, including:

  * data encryption at rest and in transit
  * restricted access to resources in accordance with operational requirements
  * strict authentication requirements to query endpoints
  * role-based access control

ACP is spread across multiple availability zones, providing three different data centres within a region. In the event of a prolonged outage for an entire AWS region, the ACP support team can recreate Kubernetes clusters, tenant applications and shared services such as ACP Hub, typically within a few hours.

Recovery of clusters, applications and services hosted on ACP are subject to considerations set out for the Production Ready criteria. See [Service Lifecycle][service_lifecycle] for more information.

For more information on security and disaster recovery, raise a request on [ACP Support][support].



## Reusable Components

We have also developed the following open-source components you can utilise for your project:

  * [Terraform modules][terraform]: including create network load balancers, setup endpoint services, and build S3 buckets
  * [Base docker images][base_images]: build container images on top of these for your project’s application environments

[dev_onboarding]: https://ukhomeoffice.github.io/application-container-platform/developer-docs/dev-setup.html
[acp_vpn]: https://access-acp.digital.homeoffice.gov.uk/ui/profiles
[ho_repo]: https://github.com/UKHomeOffice
[github_docs]: https://docs.github.com/en
[gitlab_docs]: https://docs.gitlab.com/ce/README.html
[drone_gh]: https://drone-gh.acp.homeoffice.gov.uk/
[drone_gl]: https://drone-gl.acp.homeoffice.gov.uk/
[drone_ci]: https://ukhomeoffice.github.io/application-container-platform/how-to-docs/drone-how-to.html
[drone_docs]: https://docs.drone.io/
[quay_docs]: https://quay.io/organization/ukhomeofficedigital
[ecr_docs]: https://docs.aws.amazon.com/ecr/
[artifactory]: https://artifactory.digital.homeoffice.gov.uk/artifactory/webapp/
[artifactory_docs]: https://www.jfrog.com/confluence/display/JFROG/JFrog+Artifactory
[docker_images]: https://docker.digital.homeoffice.gov.uk/artifactory/webapp/#/home
[gatekeeper]: https://www.keycloak.org/docs/latest/securing_apps/#_keycloak_generic_adapter
[keycloak]: https://www.keycloak.org/
[nginx]: https://github.com/UKHomeOffice/docker-nginx-proxy
[cert_mgr]: https://ukhomeoffice.github.io/application-container-platform/how-to-docs/cert-manager.html
[elasticsearch]: https://github.com/UKHomeOffice/docker-elasticsearch
[fluentd]: https://github.com/fluent/fluentd
[kibana]: https://github.com/UKHomeOffice/docker-kibana
[acp_kibana]: https://kibana.acp.homeoffice.gov.uk/
[support_kibana]: https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/34
[acp_sysdig]: https://sysdig.digital.homeoffice.gov.uk/#/
[sysdig_docs]: https://docs.sysdig.com/
[sysdig_inspect]: https://github.com/draios/sysdig-inspect
[sysdig_101]: https://learn.sysdig.com/
[service_lifecycle]: https://ukhomeoffice.github.io/application-container-platform/service-lifecycle.html
[support]: https://support.acp.homeoffice.gov.uk/servicedesk/customer/portals
[terraform]: https://github.com/UKHomeOffice?utf8=%E2%9C%93&q=acp-tf&type=&language=
[base_images]: https://github.com/UKHomeOffice?utf8=%E2%9C%93&q=docker-&type=&language=
[kube_example]: https://github.com/UKHomeOffice/kube-example-app
[acp_example]: https://github.com/UKHomeOffice/acp-example-app
[itnow]: https://lssiprod.service-now.com/ess