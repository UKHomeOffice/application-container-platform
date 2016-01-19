## **Vault**

### **Introduction**
Vault is a tool for securely accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, and more. Vault provides a unified interface to any secret, while providing tight access control and recording a detailed audit log.

A modern system requires access to a multitude of secrets: database credentials, API keys for external services, credentials for service-oriented architecture communication, etc. Understanding who is accessing what secrets is already very difficult and platform-specific. Adding on key rolling, secure storage, and detailed audit logs is almost impossible without a custom solution. This is where Vault steps in.

Examples work best to showcase Vault. Please see the use cases.

***The key features of Vault are:***

> **Secure Secret Storage**: Arbitrary key/value secrets can be stored in Vault. Vault encrypts these secrets prior to writing them to persistent storage, so gaining access to the raw storage isn't enough to access your secrets. Vault can write to disk, Consul, and more.
>
> **Dynamic Secrets**: Vault can generate secrets on-demand for some systems, such as AWS or SQL databases. For example, when an application needs to access an S3 bucket, it asks Vault for credentials, and Vault will generate an AWS keypair with valid permissions on demand. After creating these dynamic secrets, Vault will also automatically revoke them after the lease is up.
>
> **Data Encryption**: Vault can encrypt and decrypt data without storing it. This allows security teams to define encryption parameters and developers to store encrypted data in a location such as SQL without having to design their own encryption methods.
>
> **Leasing and Renewal**: All secrets in Vault have a lease associated with it. At the end of the lease, Vault will automatically revoke that secret. Clients are able to renew leases via built-in renew APIs.
>
> **Revocation**: Vault has built-in support for secret revocation. Vault can revoke not only single secrets, but a tree of secrets, for example all secrets read by a specific user, or all secrets of a particular type. Revocation assists in key rolling as well as locking down systems in the case of an intrusion.

#### **DSP Setup**
---
Vault is presently running in high-availability mode on the etcd cluster boxes and using etcd as it's storage backend.  You can review the setup and installation notes in [platform_setup](https://github.com/UKHomeOffice/dsp/blob/master/docs/platform_setup.md#vault).  Internally the service is exposed via a internal load balancer, provided by a [headless service](https://github.com/UKHomeOffice/dsp/tree/master/kube/namespace/platform/vault) in kubernetes.  Externally, although not officially required, the service is exposed via a [ELB service](https://github.com/UKHomeOffice/dsp/blob/master/stacks/templates/vault-elb.yaml). Due to the manner in which Vault handles standby nodes (only one node is master at any one time) a proxy [Vault Proxy](#vault-proxy) is placed in front.

#### **[Vault Proxy](#vault-proxy)**

Note, is you don't intend to expose the Vault Service externally you can skip over this section. Seated behind an ELB the vault service standby nodes do not proxy traffic onto the master, instead the issue a 307 HTTP redirect to the advertised address of the master, which in this case is a non-routable address. The [vault proxy](https://github.com/UKHomeOffice/dsp/tree/master/kube/namespace/platform/vault-proxy) is a nginx service is configured to handle the redirect for you.

### **Vaults Paths**
Before delving into setting up backends and policies we need to speak about Vault paths. The default path of a backend is the same as the backend provider name i.e. aws secret backend is aws/, mysql is mysql/ etc etc. In order to support multiple backends, Vault provides the notion of a mount path.

Lets say we have two mysql backends

```shell
# add the mount point with a 'mysql' backend provider
$ vault mount -path=mysql/myproduct mysql

# list the mount points
$ vault mounts
Path              Type       Default TTL  Max TTL  Description
aws/              aws        system       system
cubbyhole/        cubbyhole  n/a          n/a      per-token private secret storage
mysql/myproduct/  mysql      system       system
pki/              pki        system       system
secret/           generic    system       system   generic secret storage
sys/              system     n/a          n/a      system endpoints used for control, policy and debugging
```

Or you have two projects which have different CA's

```shell
$ vault mount -path=certs/myproduct pki

$ vault mount -path=certs/myproduct pki
Successfully mounted 'pki' at 'certs/myproduct'!

$ vault mounts
Path              Type       Default TTL  Max TTL  Description
aws/              aws        system       system
certs/myproduct/  pki        system       system
cubbyhole/        cubbyhole  n/a          n/a      per-token private secret storage
mysql/myproduct/  mysql      system       system
pki/              pki        system       system
secret/           generic    system       system   generic secret storage
sys/              system     n/a          n/a      system endpoints used for control, policy and debugging
```

#### **Vault Policies**

Backends in vault are mapped into a virtual directory structure, ACL's or policies simply provide a means of enforcing read and write access on a path.

```shell
# is required in order to allow the user to login via userpass backend
path "auth/userpass/login/*" {
  policy = "write"
}

# allowing the vault-sidekick to revoke a lease
path "sys/revoke" {
  policy = "write"
}

# allow the sidekick to renew on a lease
path "sys/renew" {
  policy = "write"
}

# allow them to read the platform_tls secret
path "secret/platform/platform_tls" {
  policy = "read"
}

# give them access to their own secrets namespace
path "myproduct/secrets/*" {
  policy = "write"
}

# give them access to their own aws namespace
path "myproduct/aws/*" {
  policy = "read"
}

path "myproduct/mysql/*" {
  policy = "read"
}
```

#### **Project Example**
-----
Note, the layout given here is not an absolute; depending on the setup and requirements you might decide using additional mount points isn't warranted and place everything within their respective cubbyhole's.

 - **Adding the MyProduct user and policy**

```shell
$ vault policy-write myproduct_policy policies/myproduct.hcl
Policy 'myproduct_policy' written.
$ vault write auth/userpass/users/myproduct password=kdlskdlskdsifwsofhwsf policies=myproduct_policy
Success! Data written to: auth/userpass/users/myproduct
```

 - **Adding the IAM credentials**

```shell
# Create a AWS namespace for the project

$ vault mount -path=myproduct/aws aws
Successfully mounted 'aws' at 'myproduct/aws'!
$ vault write myproduct/aws/config/root access_key=ACCESS_KEY secret_key=SECRET_KEY region=eu-west-1
Success! Data written to: myproduct/aws/config/root

# Adding a IAM policy the provides write accces to a S3 backup bucket
$ vault write myproduct/aws/roles/myproduct_s3_backup_access policy="@secrets/aws/myproduct_s3_backup_access.json"
Success! Data written to: myproduct/aws/roles/myproduct_s3_backup_access

# Read back the policy
$ vault read myproduct/aws/roles/myproduct_s3_backup_access
Key   	Value
policy	{"Version":"2012-10-17","Statement":{"Effect":"Allow","Action":["s3:Put*","s3:List*"],"Resource":"arn:aws:s3:::myproduct-backups/*"}}

# Test the credentials are working
$ vault read myproduct/aws/creds/myproduct_s3_backup_access
Key            	Value
lease_id       	myproduct/aws/creds/myproduct_s3_backup_access/4fa94f08-d563-f4d7-2076-bb8eac9f3428
lease_duration 	3600
lease_renewable	true
access_key     	ACCESS_KEY
secret_key     	SECRET_KEY

# Revoke all leases under the path
$ vault revoke -prefix=true myproduct/aws/creds/
```

Go off and create a RDS instance in amazon, host: myproduct.cx3pq0kqhcge.eu-west-1.rds.amazonaws.com

We can now provision a mysql backend to give our pods database credentials

```shell
$ vault mount -path=myproduct/mysql mysql
Successfully mounted 'mysql' at 'myproduct/mysql'!
$ vault write myproduct/mysql/config/connection value="root:PASSWORD@tcp(myproduct.cx3pq0kqhcge.eu-west-1.rds.amazonaws.com:3306)/"
Success! Data written to: myproduct/mysql/config/connection

# Add a default lease policy
$ vault write myproduct/mysql/config/lease lease=1h lease_max=24h

# Add a template policy for create a credential in the db instance
$ vault write myproduct/mysql/roles/readonly sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON myproduct.* TO '{{name}}'@'%';"

# Connecting to the mysql instance for verification

$ docker run -ti --rm mysql bash
root@6dfa66b00b1e:/# mysql -h myproduct.cx3pq0kqhcge.eu-west-1.rds.amazonaws.com -u root -p
mysql> select User from mysql.user;
+----------+
| User     |
+----------+
| root     |
| rdsadmin |
+----------+
2 rows in set (0.00 sec)

$ vault write myproduct/mysql/roles/readonly sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON myproduct.* TO '{{name}}'@'%';"
Success! Data written to: myproduct/mysql/roles/readonly
$ vault read myproduct/mysql/creds/readonly
Key            	Value
lease_id       	myproduct/mysql/creds/readonly/038f4cec-de3c-3e3a-570d-e77d317d789c
lease_duration 	3600
lease_renewable	true
password       	78e0377e-755c-4792-6014-02c45506844c
username       	userpass-r-3f1b2

mysql> select User from mysql.user;
+------------------+
| User             |
+------------------+
| root             |
| userpass-r-3f1b2 |
| rdsadmin         |
+------------------+
3 rows in set (0.00 sec)
```

#### **Kubernetes**

Early in the decision over using Vault, the consensus was to use a [generic container](https://github.com/UKHomeOffice/vault-sidekick) rather than hard-coding vault into our applications. This has numerous benefits

* It free's the application from having to handle an implementation of accessing, renewing, revoking Vault.
* It keep's the application generic, all they care about is files, how those are delivered is irrelevant; easier for testing.
* To vault or not to vault? the eco-system of container is a fast moving thing, things that are cool today are crap tomorrow and next month no doubt there be something event better. The approach that Vault brings, short-term access to resources is more important than the implementation.
* There's a lot of cross-over from proposal's thrown around in Kubernetes; dynamic secrets, config api, encryptiona dn key rotation all have proposal's and as Kubernetes becomes more plugin friendly, chances are will be implemented via a plugin is a secrets delivery mechanism
* And indeed, some of the application will be outside of scope; third-party and simple open-source components which would make diverge's.

Integration with Kubernetes requires a vault-side pod to access and delivery the resource the project app. Below is a snippet from a replication controller file.

````YAML
- name: vault-sidekick
  image: quay.io/ukhomeofficedigital/vault-sidekick:latest
  imagePullPolicy: Always
  args:
    - -logtostderr=true
    - -v=4
    - -tls-skip-verify=true
    - -auth=/etc/vault/vault.yml
    - -output=/etc/secrets
    - -cn=secret:secret/platform/platform_tls:fmt=cert,up=12h,file=platform_tls
    - -cn=aws:myproduct/aws/creds/myproduct_s3_backup_access:update=6h,fmt=yaml,file=s3access.yaml
    - -cn=mysql:myproduct/mysql/creds/readonly:renew=true,update=30m,fmt=yaml,file=db.yaml
  env:
    - name: VAULT_ADDR
      value: https://vault.platform.cluster.local:8200
  volumeMounts:
    - name: vault
      mountPath: /etc/vault
    - name: secrets
      mountPath: /etc/secrets
- name: nginx-tls-sidekick
  image: quay.io/ukhomeofficedigital/nginx-tls-sidekick
  imagePullPolicy: Always
  args:
    - ./run.sh
    - -p
    - 443:127.0.0.1:4180:platform_tls
  volumeMounts:
    - name: secrets
      mountPath: /etc/secrets
    - name: vault
      mountPath: /etc/vault
volumes:
  - name: secrets
    emptyDir: {}
  - name: vault
    secret:
      secretName: vault
````
