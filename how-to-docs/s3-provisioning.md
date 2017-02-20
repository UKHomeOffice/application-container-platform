# Provisioning a AWS S3 Service into the Platform

In this example env is _dev_ and the service_name is _myexample_

## AWS S3 Service Prerequisites

The following are required before continuing though this guide:

* AWS credentials for the correct platform environment
* Drone.io installation and configuration inline with the [Drone CI Guide](../how-to-docs/drone-how-to.md)
* Kubernetes installation and configuration inline with the [Devopment Setup Guide](../developer-docs/dev_setup.md)
* DevOps gitlabs access 

## Creation of the IAM access credentials

Login to AWS console with profile hod-dsp-dev. 

Create IAM user of the format **MYEXAMPLE_DEV_S3** 

Create an AWS access key, for **only** type _Programmatic access_ as this is a machine account. (This user has no perms is OK) and choose to download the credentials csv. The format will be ``` [MYEXAMPLE_DEV_S3,,S3_IAM_ACCESS_KEY,S3_IAM_SECRET_KEY]``` the second (password) field should be blank. Remain in the AWS console.


## Enabling KMS Encryption

Back to the AWS IAM console, select encryption keys (it may misleadingly present a _create your first key_ page, ignore and click) and then the create button.

Select the correct region, then create key..

* Create Alias (myexample-dev-s3) and Description  (Just an example), ensure Key Material Origin is KMS 
* Define Key Administrative Permissions, give yourself permissions to delete this key for now.
* Define Key Usage Permissions, do not add to an  IAM user, click through.
* Preview Key Policy if you wish.

Choose finish to create the key, and **note the KMS uuid presented to you** for use in the stacks config below. 

Docs: http://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html


## Configuring Stacks

Retrieve provisioning git repos and create a feature branch for your resource request.
Pushing starts CI.


```
git clone ssh://git@gitlab.digital.homeoffice.gov.uk:2222/Devops/stacks-hod-platform.git
cd stacks-hod-platform
git checkout -b myexample-s3
```

Most new provisioning requests are similar, copying an existing template in ```stacks/templates/hod-dsp-[env]``` 

For an S3 template, change the KMS key at the top, with the key obtained during the KMS section on console.


```
{% set service_name = 'myexample' %}
{% set kms_id = '58855abe-2f87-4e61-9ac1-ef29b6254438' %}
{% set aws_user = service_name.upper() + '_' + env.upper() + '_S3' %}
{% set service_bucket = service_name + '-' + env + region %}
```

* Check your edits for errors as there may not be full upstream validation in the CI.
* git commit your change and include the request ID in the message.
* git push and follow the CI attempts to run the provisioning continue if build successful (currently gitlab and drone)
* Create merge/pull request in the repo and advertise peer review on slack.
* Await LGTM and accept the merge request yourself.
* Follow the drone CI provisioning into the platform.


## Populating the kubernetes secrets

This script creates the kubernetes secrets yaml. Add this script to a shell file named mk-s3-secrets.sh:

```
#!/bin/bash
# Create kubernetes secets with S3 credentials

S3_BUCKET="$1"
S3_B64="$(echo -n ${S3_BUCKET} | base64)"
SECRET_NAME="s3-${S3_BUCKET}"

while IFS=, read USER Password ACCESS SECRET Others
do
  # base64 encode secrets
  S3_IAM_ACCESS_KEY=$(echo -n ${ACCESS} | base64)
  S3_IAM_SECRET_KEY=$(echo -n ${SECRET} | base64)

# example kubernetes config file
cat - > k8s-secret.yaml <<EoF 
apiVersion: v1
data:
  access_key_id: ${S3_IAM_ACCESS_KEY}
  secret_access_key: ${S3_IAM_SECRET_KEY}
  bucket_name: ${S3_B64}
kind: Secret
metadata:
  name: ${SECRET_NAME}
type: Opaque
EoF

done

cat k8s-secret.yaml
```

The S3 _Access key ID_ & _Secret access key_ will be presented to the end users as base64 encoded secrets in the relevent kubernetes namespace. Use the S3 bucket name as the Kubernetes secret name as a good convention.

```
sed -i '1d' credentials.csv # snip the header from the downloaded AWS IAM credentials
mk-s3-secrets.sh myexample-deveu-west-1 < credentials.csv
```
Deploy the kubernetes secrets, make sure kubectl config has been setup according to the guide.

```
kubectl --context=<kube-config-context> get namespaces
kubectl --context=<kube-config-context> --namespace=<kube-namespace> create -f k8s-secret.yaml
```
Check secrets are visible in the destination namespace.

```
kubectl --context=<kube-config-context> --namespace=<kube-namespace> get secrets/<myexample> -o yaml
```
Note the secrets name to be issued back the user who requested the s3 bucket.