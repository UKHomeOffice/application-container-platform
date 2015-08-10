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

## Vault

### Start Vault service

Login to one of the nodes, either etcd or compute, clone this repo and start
the services:

```
$ ssh -l core -A <hostname or IP>
$ git clone git@github.com:UKHomeOffice/dsp.git
$ cd dsp/units/vault
$ fleetctl start vault.service
```

### Initialize Vault
```
$ vault init -key-shares=1 -key-threshold=1

Key 1: 0efc52423a2c31359cb74a91e47b6ccf8df658e0a3c1dfeb64ffbd30b0e45c01
Initial Root Token: 0599040b-eb9e-f6fe-9872-a03db5e2eeee

Vault initialized with 1 keys and a key threshold of 1. Please
securely distribute the above keys. When the Vault is re-sealed,
restarted, or stopped, you must provide at least 1 of these keys
to unseal it again.

Vault does not store the master key. Without at least 1 keys,
your Vault will remain permanently sealed.
```

### Unseal Vault

Now you will need to encrypt the `Key 1` and upload it to S3 secrets bucket.
After that you need to stop and start `vault.service` again for the vault to be
unsealed automatically.

* Encrypt the key
```
$ aws --profile hod-dsp kms encrypt \
  --key-id 448a33c3-2312-1234-9635-4cfecff64c7a \
  --plaintext "0efc52423a2c31359cb74a91e47b6ccf8df658e0a3c1dfeb64ffbd30b0e45c01" \
  --query CiphertextBlob --output text | base64 -d > vault-unseal.key.encrypted
```

* Upload encrypted key to S3 secrets bucket
```
$ aws --profile hod-dsp \
  s3 cp vault-unseal.key.encrypted s3://dev-platform-secrets-eu-west-1
```

* Restart vault service
```
$ fleetctl stop vault.service
$ fleetctl start vault.service
```

* Check vault
```
$ vault status
Sealed: false
Key Shares: 1
Key Threshold: 1
Unseal Progress: 0

High-Availability Enabled: true
  Mode: standby
  Leader: https://10.50.12.200:8200
```


## Start Kubernetes Services

Login to one of the nodes, either etcd or compute, clone this repo and start
the services:

```
$ ssh -l core -A <hostname or IP>
$ git clone git@github.com:UKHomeOffice/dsp.git
$ cd dsp/units/kubernetes
$ fleetctl start kube-*
```

Give it a couple of minutes and you should have a secure and fully working
Kubernetes cluster.

