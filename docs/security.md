# Security

This document describes what security measures have been applied when designing
this platform, current risks and attack areas.

## Network

DSP runs in its own AWS VPC. Secure subnet, where etcd lives, has no access to
compute subnet, however compute subnet has access to etcd and vault.

External ELBs are only allowed to access upstream application on specific
ports in compute subnet.

## Access Controls

### AWS Account

AWS access is controlled via IAM users, groups and policies.


### SSH

Access to both etcd and compute nodes over SSH is allowed from known Home
Office IPs.


## TLS Everywhere

All platform endpoints, including kubernetes, etcd, vault, are secured with TLS
certificates. CA and TLS certs/keys are managed using cfssl tool, more
information can be found [here](ca_tls.md). With the help of AWS KMS service and
S3, we can securely store and deploy TLS certs/keys onto specific machines. TLS
certs/keys are never stored on disk, they get deployed onto a tmpfs (in memory
file system) which gets destroyed as soon as the service needing them is
restarted or stopped.

## Attack Surface

### Internal

Currently the biggest internal attack surface is etcd, because it does not have
authentication (see known issues below). It an attacker gains access to either
compute of secure subnets, they will be able to reach etcd and cause damage, by
potentially executing arbitrary code.


### External

At this point, this platform runs a BRP application only, which is a simple web
form application. There is no authentication, user accounts, nor management
console. BRP application entrypoint is an ELB with TLS.

Kubernetes defines a reasonable set of security best practices that allows
processes to be isolated from each other, from the cluster infrastructure, and
which preserves important boundaries between those who manage the cluster, and
those who use the cluster. Each process is isolated in a container from other
processes within a kubernetes pod. If an attacker gains access to an
application container, they will be able to see a single application process,
not other containers within the same pod. More information can be found in
[kubernetes documentation](http://kubernetes.io/v1.0/index.html).


## Known Issues

### Etcd Access

As of etcd version 2.1.x, there is an experimental authentication support, but
since etcd is used by so many components of this platform, not every component
support etcd auth implementation yet.


### Prod CA Management

The [CA and TLS document](ca_tls.md) describes how a CA gets created and TLS
certs signed, but we still need to solve a problem of where we store CA keys
and who has access to it for production.

A potential place where CA key could be stored is in vault, but this needs to
be implemented, which has issues too (see below).


### Vault Keys

When vault is initialized for the first time, it spits out a root key. The root
key is supposed to be used only once to create users and tokens, then the root
key must be forgotten.


### Kubernetes API

Partially, due to lack of proper Kubernetes user management support there is a
static token used to access the API.

