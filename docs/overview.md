# Overview

This documents describes high level principles and technologies used to build
the platform.

Digital Services Platform is combined of various open source technologies. Main
components are the following:

* [AWS](https://aws.amazon.com) - cloud hosting
* [CoreOS](https://coreos.com/) - immutable Linux operating system
* [etcd](https://coreos.com/etcd/) - distributed key value store
* [Kubernetes](https://kubernetes.io) - cluster container manager
* [Docker](https://www.docker.com/) - container runtime engine
* [Vault](https://vaultproject.io/) - tool for managing secrets

The platform infrastructure is defined in CloudFormation templates using
[stacks tool](https://github.com/State/stacks). Templates can be found in
[stacks/templates](../stacks/templates) directory.

Each environment runs in its own VPC (AWS Virtual Private Cloud). A VPC is
spread across 3 availability zones (AZs) in Amazon's Ireland region. There are
two sets of subnets, both are spread across 3 AZs and that allows AWS to spread
machines across all AZs automatically. First group of subnets is called secure,
this is where etcd and vault cluster lives. The second one is called compute
and is used for running kubernetes and docker.

Amazon Elastic Load Balancers (ELBs) are used to load balance external traffic
between healthy compute nodes as well as terminate TLS.

All platform endpoints, including kubernetes, etcd, vault, are secured with TLS
certificates. CA and TLS certs/keys are managed using cfssl tool, more
information can be found [here](ca_tls.md). With the help of AWS KMS service and
S3, we can securely store and deploy TLS certs/keys onto specific machines. TLS
certs/keys are never stored on disk, they get deployed onto a tmpfs (in memory
file system) which gets destroyed as soon as the service needing them is
restarted or stopped.

AWS Auto Scaling Groups, CoreOS Linux distribution and kubernetes play a key
role in Digital Service Platform scalability and ability to recover from
failure. CoreOS itself is an immutable operating system designed to orchestrate
system updates within the cluster. Its immutable nature prevents a
configuration drift.

Kubernetes gives us an ability to manage docker containers runtime and group
them into so called pods. A pod is an atomic deployment unit and can consist of
one or more containers which define an application or a logical task. Because
all our CoreOS compute nodes are identical, we can quickly scale our compute
resources, which Kubernetes can automatically make use of. We no longer have to
think at a single node level.

An experimental vault service is provided. Vault can be used to manage PKI
requesting and issing short lived TLS keys for internal platform services.
Vault can also provide temporary AWS API access keys and much more.

