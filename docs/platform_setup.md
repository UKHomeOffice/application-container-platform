# Platform Setup

## Prerequisites

- AWS API keys
- stacks
- cfssl

## TLS Keys and Secrets

**TODO(vaijab)**

## Launch AWS CloudFormation Stacks

Set `STACKS_ENV` variable to `dev` for example. This is going to used as an
environment name.

```
$ export STACKS_ENV=dev
```

* First, we need to create infrastructure resources: vpc, security groups,
  subnets, etc:

```
$ stacks -p hod-dsp create -e ${STACKS_ENV} -t templates/infra.yaml ${STACKS_ENV}-infra
```

* Wait for the infra stack to be in `CREATE_COMPLETE` state:

```
$ stacks -p hod-dsp list
dev-infra  CREATE_COMPLETE
```

* Next step is to create an etcd cluster:

```
stacks -p hod-dsp create -e ${STACKS_ENV} -t templates/coreos-etcd.yaml ${STACKS_ENV}-coreos-etcd
```

* Once etcd cluster is formed, compute stack can be launched next:

```
stacks -p hod-dsp create -e ${STACKS_ENV} -t templates/coreos-compute.yaml ${STACKS_ENV}-coreos-compute
```

## Start Kubernetes Services

Login to one of the nodes, either etcd or compute, clone this repo and start the services:

```
$ ssh -l core -A <hostname or IP>
$ git clone git@github.com:UKHomeOffice/dsp.git
$ cd dsp/units/kubernetes
$ fleetctl start kube-*
```

Give it a couple of minutes and you should have a secure and fully working
Kubernetes cluster.

