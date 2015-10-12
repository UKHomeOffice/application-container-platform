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

AWS_PROFILE is used if set by the aws cli so no further commands for AWS require setting of a profile
however stacks does require it to be explicitly set

```bash
$ export ENV=dev
$ export KUBE_TOKEN=$(uuidgen)
$ export SKY_DNS_KUBE_TOKEN=$(uuidgen)
$ export KMS_KEY_ID=<replace me>
$ export AWS_PROFILE=<replace me>
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


### Generate Kubernetes Secrets and Configs

Make a note of `KUBE_TOKEN` because that's what you will be using to talk to
kubernetes API for now.

The user attached to the `KUBE_TOKEN` is also used by the kubernetes processes to communicate with the API as such it needs to exist in the auth-policy that is used for your environment.
The user attached to the `SKY_DNS_KUBE_TOKEN` is required to enable the sky dns service to talk to kubernetes

```bash
$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(echo -e "${KUBE_TOKEN},kube,kube\n${SKY_DNS_KUBE_TOKEN},skydns,skydns")" \
  --query CiphertextBlob \
  --output text | base64 --decode > tokens.csv.encrypted
```


```bash
$ cat <<EOF > kubeconfig
apiVersion: v1
kind: Config
preferences: {}
contexts:
- context:
    user: kube
  name: default
current-context: default
users:
- name: kube
  user:
    token: ${KUBE_TOKEN}
EOF
```


### Encrypt Keys, Secrets and Configs

* **etcd**
```
$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat etcd.pem)" \
  --query CiphertextBlob \
  --output text | base64 --decode > etcd-crt.pem.encrypted

$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat etcd-key.pem)" \
  --query CiphertextBlob \
  --output text | base64 --decode > etcd-key.pem.encrypted
```

* **vault**
```
$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat vault.pem)" \
  --query CiphertextBlob \
  --output text | base64 --decode > vault-crt.pem.encrypted

$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat vault-key.pem)" \
  --query CiphertextBlob \
  --output text | base64 --decode > vault-key.pem.encrypted
```

* **kube-apiserver**
```
$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat kube-apiserver.pem)" \
  --query CiphertextBlob \
  --output text | base64 --decode > kube-apiserver-crt.pem.encrypted

$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat kube-apiserver-key.pem)" \
  --query CiphertextBlob \
  --output text | base64 --decode > kube-apiserver-key.pem.encrypted
```

* **kubeconfig**
```
$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat kubeconfig)" \
  --query CiphertextBlob \
  --output text | base64 --decode > kubeconfig.encrypted
```

* **auth-policy**
Confirm that the user you declared in the tokens file above is in your environment auth policy and has the relevant access ( for dev this should be everything ).
Confirm that the skydns user above is in your environment auth policy. At present granular auth policies aren't working in kubernetes, however when they are you will be able to give readonly access to endpoints as below:
```json
{"user":"skydns", "readonly": true, "resource": "endpoints"}
```

```
$ aws kms encrypt --key-id ${KMS_KEY_ID} \
  --plaintext "$(cat ../kube/${ENV}/auth-policy.json)" \
  --query CiphertextBlob \
  --output text | base64 --decode > auth-policy.json.encrypted
```


### Upload TLS Keys and Secrets

First we need to make sure that the secrets bucket exists.

```bash
$ aws s3 mb s3://${ENV}-platform-secrets-eu-west-1

```

```bash
for n in $(ls -1 *.encrypted); do
  aws s3 cp ${n} s3://${ENV}-platform-secrets-eu-west-1
done
```

### Cleanup

```bash
$ cd ..; rm -rf tmp
```

## Environment Keypairs

* **Create a default keypair for the environment**

The config.yaml should have a ssh_key_name: [NAME] varaible e.g. dev-defaut or prod-default, ensure you have created the keypair in your AWS account.

## Launch AWS CloudFormation Stacks

* **First, we need to create infrastructure resources**
```
$ stacks -p $AWS_PROFILE create -e ${ENV} -t templates/infra.yaml ${ENV}-infra
```

* **Wait for the infra stack to be in `CREATE_COMPLETE` state**
```
$ stacks -p $AWS_PROFILE list
dev-infra  CREATE_COMPLETE
```

* **Next step is to create an etcd cluster**
```
stacks -p $AWS_PROFILE create -e ${ENV} -t templates/coreos-etcd-volumes.yaml ${ENV}-coreos-etcd-volumes
```

Wait for the volumes stack to finish creating, it usually takes less than 30 seconds

```
stacks -p $AWS_PROFILE create -e ${ENV} -t templates/coreos-etcd.yaml ${ENV}-coreos-etcd
```

* **Once etcd cluster is formed, compute stack can be launched next**
```
stacks -p $AWS_PROFILE create -e ${ENV} -t templates/coreos-compute.yaml ${ENV}-coreos-compute
```

* **Create an ELB for Kubernetes API**
```
stacks -p $AWS_PROFILE create -e ${ENV} -t templates/kubernetes-elb.yaml ${ENV}-kubernetes-elb
```

You will need to attach the ELB to the compute auto scaling group. See
[here](apps_deployment.md) how to do that.

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

### Find a node that is running vault
```
$ fleetctl list-units | grep vault.service
vault.service     60cb84c3.../10.50.11.200  active  running
vault.service     71bf12d4.../10.50.12.200  active  running
```

### Initialize Vault
```
$ VAULT_ADDR=https://10.50.11.200:8200 vault init -key-shares=1 -key-threshold=1

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
$ aws kms encrypt \
  --key-id ${KMS_KEY_ID} \
  --plaintext "0efc52423a2c31359cb74a91e47b6ccf8df658e0a3c1dfeb64ffbd30b0e45c01" \
  --query CiphertextBlob --output text | base64 --decode > vault-unseal.key.encrypted
```

* **Upload encrypted key to S3 secrets bucket**
```
$ aws s3 cp vault-unseal.key.encrypted s3://${ENV}-platform-secrets-eu-west-1
```

* **Restart vault service**
```
$ fleetctl stop vault.service
$ fleetctl start vault.service
```

* **Check vault**
```
$ VAULT_ADDR=https://10.50.11.200:8200 vault status
Sealed: false
Key Shares: 1
Key Threshold: 1
Unseal Progress: 0

High-Availability Enabled: true
  Mode: standby
  Leader: https://10.50.12.200:8200
```

## Setup SkyDNS

The SkyDNS service is required if you are to use the standard configuration for the platform. This is because kubelets are configured to use the Sky DNS service for DNS.

To start the Sky DNS service you will first need to update the sky-dns-secrets.yaml file.
- Update the kubetoken in the file with the SKY_DNS_KUBE_TOKEN value. DO NOT COMMIT THIS FILE!! The token is sensitive
- Base64 encode the secret. You should end up with line 7 saying "kubeconfig: mybase64encodedconfig"
- Create the services as follows
``` bash
$ cd kube/cluster/skydns/
$ kubectl --namespace=services create -f skydns-secrets.yaml
$ kubectl --namespace=services create -f skydns-rc.yaml
$ kubectl --namespace=services create -f skydns-service.yaml
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

## Enable Kubernetes Logging

If you want to push docker logs with kubernetes metadata attached to Cloudwatch
Logs, then you can start an additional fleet unit.

Logstash service expects `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to be
set. Best way to do that is via secrets.

```bash
$ cat logstash_kubernetes_aws_key
AWS_ACCESS_KEY_ID=<REPLACE ME>
AWS_SECRET_ACCESS_KEY=<REPLACE ME>
```

Assuming you're already logged in to one of the nodes and have cloned the repo.

```bash
$ fleetctl start units/misc/logstash-kubernetes.service
```

 