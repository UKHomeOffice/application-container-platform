#### **VPN & External Access**

External access to the cluster is provided by [OpenVPN](https://openvpn.net/index.php/open-source/documentation.html), with authentication and identity handled by the oauth provider Keycloak (and hopefully by the time you deploy this, the authentication federated off to Google Apps). The issuing of OpenVPN credentials is dynamic with token access short lived. At present the Kubernetes API and the Vault API are the only services exposed via the VPN.

> **Assumption** : you've already deployed the Vault and KubeAPI ELB stacks?

##### **Setup the VPN Stacks**

```bash
$ export ENV=dev
$ export KUBE_TOKEN=$(uuidgen)
$ export KMS_KEY_ID=<replace me>
$ export AWS_PROFILE=<replace me>
```

```shell
# creates the vpn subnets, routes and security groups
$ stacks -p $AWS_PROFILE create -e ${ENV} -t templates/vpn ${ENV}-vpn

```

- **Create the S3 Buckets and Secrets**

First create the S3 bucket used to hold the platform certificate and secrets, the name of the bucket can be found in config.yaml *e.g. secrets_vpn_bucket_name: NAME*. Once the bucket has been created upload the platform_ca,  openvpn.manifest and vault token.

```bash
$ AWS_BUCKET=<replace me>
$ AWS_DEFAULT_PROFILE=$AWS_PROFILE
$ AWS_DEFAULT_REGION=eu-west-1

$ s3secrets put -p platform/ platform_ca.pem
```

- **Generate the OpenVPN CA**

```shell
$ cd ca/dev/openvpn
# -> generate the CA for OpenVPN
$ cfssl gencert -initca openvpn-ca.json | cfssljson -bare ca
# -> generate the dhparams
$ openssl dhparam -out dh.pem 1024
# -> generate the Vault Certificate and sign by the CA above
$ cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=../../ca-config.json -profile=server openvpn-csr.json | cfssljson -bare openvpn
```

- **OpenVPN Config & Service**

Although the config and service manifest could be bundled with the userdata, for convenience we place into s3secrets bucket; allowing
us to update the configuration simplying by restarting the service.

```shell
$ cd manifests/
$ s3secrets s3 put -p openvpn/ openvpn.conf openvpn.manifest
```

- **Vault OpenVPN Setup**

First we need to take the various secrets and place them into vault secrets;

```shell
$ vault mount -path openvpn generic
Successfully mounted 'generic' at 'openvpn'!
$ vault mounts
Default TTL  Max TTL  Description
cubbyhole/     cubbyhole  n/a          n/a      per-token private secret storage
openvpn/       generic    system       system   
secret/        generic    system       system   generic secret storage
sys/           system     n/a          n/a      system endpoints used for control, policy and debugging

# Create the secrets for upload, create a or json which ever you prefer from the content created above
ca.pem: |
  CONTENT
openvpn.pem: |
  CONTENT
openvpn-key.pem: |
  CONTENT
dh.pem: |
  CONTENT

# Inject into the Vault backend
$ yml2json openvpn.yml | vault write openvpn/openvpn -
Success! Data written to: openvpn/openvpn
$ vault read openvpn/openvpn
... to ensure it was correctly written
```

We need to create the vault policy and user which openvpn can use to retrieve the secrets from. Due to fact we
don't want to place these into the userdata, the user credentials are retrieved via s3secrets and mapped into
the OpenVPN container.

```shell
# Create the user
$ vault write auth/userpass/users/openvpn password=PASSWORD policies=openvpn,common
Success! Data written to: auth/userpass/users/openvpn

# Create the Vault policy which allows the 'openvpn' user access to the secrets
```

```YAML
path "openvpn/*" {
  policy = "read"
}
```

```shell
# Write the policy file to Vault
$ vault policy-write openvpn openvpn.hcl

# Create the authentication file and upload via s3secrets to the vpn bucket
$ cat vault-token.yml
method: userpass
username: openvpn
password: PASSWORD

$ s3secrets s3 ls -b dev-vpn-secrets-eu-west-1
total: 1
platform/
$ s3secrets kms ls
alias/aws/ebs                           d6c6cce6-fc60-4e10-a8af-9cdf714fa532
alias/dev-commons-eu-west-1             55e1557d-451c-4030-80f2-08b6233379ae
alias/prod-commons-eu-west-1            10e44cbb-3a98-452a-bd01-da8922be88d3
$ s3secrets s3 put -k 55e1557d-451c-4030-80f2-08b6233379ae -b dev-vpn-secrets-eu-west-1 -p openvpn/ vault-token.yml
INFO[0000] successfully uploaded the file: vault-token.yml to path: openvpn/vault-token.yml.encrypted
$ s3secrets s3 ls -l -R -b dev-vpn-secrets-eu-west-1  
total: 3
jon.shanks+commons     234 Oct 14 14:55     openvpn/vault-token.yml.encrypted
                         0 dir              platform/
jon.shanks+commons    1621 Oct 13 15:31     platform/platform_ca.pem.encrypted
```

- **VPN Cluster and ELB Stacks**

We can now create the OpenVPN cluster (a auto-scaling group or machines) and the ELB exposing the OpenVPN port.

```shell
# creates the openvpn machines
stacks -p $AWS_PROFILE create -e ${ENV} -t templates/coreos-etcd-volumes.yaml ${ENV}-openvpn
# creates the elb
stacks -p $AWS_PROFILE create -e ${ENV} -t templates/openvpn-elb ${ENV}-openvpn-elb
# associate the elb with the vpn auto-scaling group
$ aws --profile $AWS_PROFILE autoscaling attach-load-balancers \
  --auto-scaling-group-name dev-coreos-compute-CoreOSComputeScalingGroup-MW0AEFC467S \
  --load-balancer-names dev-openvpn-BRPELB-IU7XN24U7CVI
```

- **OpenVPN Access Service**

The [openvpn-authd](https://github.com/UKHomeOffice/openvpn-authd) is responsible for dishing out the access tokens for OpenVPN access. The service is secured and authentication via the Keycloak oauth service. The basic gist being, you go to the site, the proxy doesn't see a session cookie so redirects you to a AS (authentication service) requesting a offline_access scope *(essentially a access + refresh token)*. Once the user has logged in and authenticated, use to redirected back and the authentication code is exchanged with the AS, a cookie session is dropped in a the proxy can now proxy the requests onto the secured service.

[Openvpn-authd] essentially does nothing more than request a short-lived certificate via [Vault](https://github.com/hashicorp/vault) and templates out a OpenVPN config to the user.

- **Create application in Keycloak**

Login via the keycloak admin service https://keycloak-|PLATFORM|-|ENV|.|DOMAIN|.homeoffice.gov.uk and create a new realm named DSP.

```shell
# deploy the openvpn-authd service  - note you need to fill in the various variables in
# the rc file, note the external dns name variables are the dns names you are giving
# to the below stack

# create the namespace
$ kubectl create -f openvpn.yml
# create the controller and service
$ kubectl create -f openvpn-authd-rc-.yml
$ kubectl create -f openvpn-authd-svc.yml
```

- **Create the PKI Backend in Vault**

The certificates for authentication are issues via Vault, thus we need to create a pki backend and ensure we have a user and policy which permits Access

```shell
# create the vault pki backend
$ vault mount -path=openvpn-authd/ pki

# add the openvpn ca we created at the beginning - NOTE, the order key -> cert is important
$ cat ca-key.pem ca.pem | vault write openvpn-authd/config/ca pem_bundle="-"

# create a policy for the ca
vault write openvpn-authd/roles/openvpn allow_any_name=true max_ttl="6h"

# ensure we have the policy
$ vault policies
common
openvpn
openvpn-authd
platform
platform_tls
root

```

- **Create the ELB stack**

```shell
# create the elb for access service
stacks -p $AWS_PROFILE create -e ${ENV} -t templates/kube-elb ${ENV}-openvpn-authd-elb

# associate the elb with the vpn auto-scaling group
$ aws --profile $AWS_PROFILE autoscaling attach-load-balancers \
  --auto-scaling-group-name dev-coreos-compute-CoreOSComputeScalingGroup-MW0AEFC467S \
  --load-balancer-names dev-openvpn-authd-BRPELB-IU7XN24U7CVI

```
