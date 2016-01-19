#### **KeyCloak**

[Keycloak](http://keycloak.jboss.org/docs) is an SSO solution for web apps, mobile and RESTful web services. It is an authentication server where users can centrally login, logout, register, and manage their user accounts. The Keycloak admin UI can manage roles and role mappings for any application secured by Keycloak. The Keycloak Server can also be used to perform social logins via the user's favorite social media site i.e. Google, Facebook, Twitter etc.

##### **Setup Keycloak**

* **Set env variables**

AWS_PROFILE is used if set by the aws cli so no further commands for AWS require setting of a profile
however stacks does require it to be explicitly set

```bash
$ export ENV=dev
$ export KUBE_TOKEN=$(uuidgen)
$ export KMS_KEY_ID=<replace me>
$ export AWS_PROFILE=<replace me>
```

* **Create the MySQL database**

```bash
$ stacks -p $AWS_PROFILE create -e ${ENV} -t templates/keycloak-rds.yaml ${ENV}-keycloak-rds
```

Once the instance is up and running, jump into the instance and change the root password, create a keyclock schema and user to access it

```bash
$ docker run -ti --rm mysql bash
$ mysql -h <RDS_HOSTNAME> -u root -p<ROOT_PASSWORD>
$ mysql> use mysql;
$ mysql> update user set password=PASSWORD("NEW-ROOT-PASSWORD") where User='root';
$ mysql> flush privileges;
# You should probably logout and login just to verify the password change at this point
$ mysql> create database keycloak;
$ mysql> grant all on keycloak.* to keycloak@'10.50.%' identified by 'PASSWORD';
```

At this point you should take the DNS name of the RDS instance keycloakdb-ENV.DNS_ZONE and place into the DNS provider

* **Push out the keycloak service**

```bash
# Ensure you update the keycloak environment variables are updated and populated with the credentials
$ cd kube/namespace/platform/
$ kubectl create -f keyclock/
```

* **Create the ELB**

```bash
# create the external load balancer
$ stacks -p $AWS_PROFILE create -e ${ENV} -t templates/keycloak-elb.yaml ${ENV}-keycloak-elb
# list the auto scaling groups
$ aws --profile $AWS_PROFILE autoscaling describe-auto-scaling-groups | jq .AutoScalingGroups[].AutoScalingGroupName
# associate the elb to the autoscaling group
$ aws --profile $AWS_PROFILE autoscaling attach-load-balancers \
  --auto-scaling-group-name dev-coreos-compute-CoreOSComputeScalingGroup-1LUE0A0D3FEHM \
  --load-balancer-names dev-keycloak-e-ELB-1XJUSGXO9XMBL
```
