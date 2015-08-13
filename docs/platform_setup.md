# Platform Setup


## Prerequisites

- [AWS cli tools](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- AWS API keys
- [stacks tool](https://github.com/State/stacks)
- [cfssl tool](https://github.com/cloudflare/cfssl)

Below commands could be easily put in a script, but for now, let's understand
what pieces are needed for the platform and then we can script it.

* **Clone this repo**
```bash
$ git clone git@github.com:UKHomeOffice/dsp.git
```

* **Let's create a `tmp` directory to store files while we're working with them**
```bash
$ mkdir -p tmp; cd tmp
```

* **Set env variables**
```bash
$ export ENV=dev
$ export KUBE_TOKEN=$(uuidgen)
$ export KMS_KEY_ID=<replace me>
```


## Create TLS Keys and Secrets

### Generate TLS Keys for Services

First of all, make sure you followed [CA and TLS guide](ca_tls.md) and have a
working CA setup.

We want to have TLS everywhere and for that we need to generate initial TLS
certs for services like etcd, vault and kubernetes.

* **etcd**
```
$ cfssl gencert -config=../ca/ca-config.json -ca-key=../ca/${ENV}/ca-key.pem \
  -ca=../ca/${ENV}/ca.pem \
  -profile=server ../ca/etcd-csr.json | cfssljson -bare etcd
```

* **vault**
```
$ cfssl gencert -config=../ca/ca-config.json -ca-key=../ca/${ENV}/ca-key.pem \
  -ca=../ca/${ENV}/ca.pem \
  -profile=server ../ca/vault-csr.json | cfssljson -bare vault
```

* **kube-apiserver**
```
$ cfssl gencert -config=../ca/ca-config.json -ca-key=../ca/${ENV}/ca-key.pem \
  -ca=../ca/${ENV}/ca.pem \
  -profile=server ../ca/kube-apiserver-csr.json | cfssljson -bare kube-apiserver
```


### Generate Kubernetes Secrets

Make a note of `KUBE_TOKEN` because that's what you will be using to talk to
kubernetes API for now.

```bash
$ aws --profile hod-dsp kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(echo ${KUBE_TOKEN},${ENV}-dsp,${ENV}-dsp)" \
  --query CiphertextBlob \
  --output text | base64 -d > tokens.csv.encrypted
```

```bash
$ cat <<EOF > kubeconfig
apiVersion: v1
kind: Config
preferences: {}
contexts:
- context:
    user: ${ENV}-dsp
  name: default
current-context: default
users:
- name: ${ENV}-dsp
  user:
    token: ${KUBE_TOKEN}
EOF
```


### Encrypt Keys and Secrets

* **etcd**
```
$ aws --profile hod-dsp kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat etcd.pem)" \
  --query CiphertextBlob \
  --output text | base64 -d > etcd-crt.pem.encrypted

$ aws --profile hod-dsp kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat etcd-key.pem)" \
  --query CiphertextBlob \
  --output text | base64 -d > etcd-key.pem.encrypted
```

* **vault**
```
$ aws --profile hod-dsp kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat vault.pem)" \
  --query CiphertextBlob \
  --output text | base64 -d > vault-crt.pem.encrypted

$ aws --profile hod-dsp kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat vault-key.pem)" \
  --query CiphertextBlob \
  --output text | base64 -d > vault-key.pem.encrypted
```

* **kube-apiserver**
```
$ aws --profile hod-dsp kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat kube-apiserver.pem)" \
  --query CiphertextBlob \
  --output text | base64 -d > kube-apiserver-crt.pem.encrypted

$ aws --profile hod-dsp kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat kube-apiserver-key.pem)" \
  --query CiphertextBlob \
  --output text | base64 -d > kube-apiserver-key.pem.encrypted
```

* **kubeconfig**
```
$ aws --profile hod-dsp kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat kubeconfig)" \
  --query CiphertextBlob \
  --output text | base64 -d > kubeconfig.encrypted
```

### Upload TLS Keys and Secrets

```bash
for n in $(ls -1 *.encrypted); do
  aws --profile hod-dsp s3 cp ${n} s3://${ENV}-platform-secrets-eu-west-1
done
```

### Cleanup

```bash
$ cd ..; rm -rf tmp
```


## Launch AWS CloudFormation Stacks

* **First, we need to create infrastructure resources**
```
$ stacks -p hod-dsp create -e ${ENV} -t templates/infra.yaml ${ENV}-infra
```

* **Wait for the infra stack to be in `CREATE_COMPLETE` state**
```
$ stacks -p hod-dsp list
dev-infra  CREATE_COMPLETE
```

* **Next step is to create an etcd cluster**
```
stacks -p hod-dsp create -e ${ENV} -t templates/coreos-etcd.yaml ${ENV}-coreos-etcd
```

* **Once etcd cluster is formed, compute stack can be launched next**
```
stacks -p hod-dsp create -e ${ENV} -t templates/coreos-compute.yaml ${ENV}-coreos-compute
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

* **Encrypt the key**
```
$ aws --profile hod-dsp kms encrypt \
  --key-id ${KMS_KEY_ID} \
  --plaintext "0efc52423a2c31359cb74a91e47b6ccf8df658e0a3c1dfeb64ffbd30b0e45c01" \
  --query CiphertextBlob --output text | base64 -d > vault-unseal.key.encrypted
```

* **Upload encrypted key to S3 secrets bucket**
```
$ aws --profile hod-dsp \
  s3 cp vault-unseal.key.encrypted s3://${ENV}-platform-secrets-eu-west-1
```

* **Restart vault service**
```
$ fleetctl stop vault.service
$ fleetctl start vault.service
```

* **Check vault**
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

