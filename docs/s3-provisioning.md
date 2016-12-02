# WiP
# Provisioning a AWS S3 Service into the Platform

This requires AWS credentials for hod-dsp-[env] to create the resources and dsp-ci for drone to deploy to the platform. In this example env is _dev_ and the service_name is _myexample_

## Creation of the IAM access credentials

Login to AWS console with profile hod-dsp-dev

Create IAM user of the format **MYEXAMPLE_DEV_S3** 

Create an AWS access key, for **only** type _Programmatic access_ as this is a machine account. (This user has no perms is OK) and choose to download the credentials csv. The format will be ``` [MYEXAMPLE_DEV_S3,,S3_IAM_ACCESS_KEY,S3_IAM_SECRET_KEY]``` the second (password) field should be blank. Remain in the AWS console.

## Populating the kubernetes secrets

Snip the header ```sed -i '1d' credentials.csv```

The ```Access key ID``` & ```Secret access key``` will be presented to the end users as base64 encoded secrets in the relevent kubernetes namespace, the script below will construct one for this example.

```
./runme.sh myexample-dev < credentials.csv
```

### script
```

!/bin/bash
# Create kubernetes secets with S3 credentials

S3_NAME="$(echo -n $1eu-west-1 | base64)"

while IFS=, read USER Password ACCESS SECRET
do
  # base64 encode secrets
  S3_IAM_ACCESS_KEY=$(echo -n ${ACCESS} | base64)
  S3_IAM_SECRET_KEY=$(echo -n ${SECRET} | base64)
  SECRET_NAME=$(echo -n ${K_SECRETS_NAME} | base64)

# example kubernetes config file
cat - > k8s-secret.yaml <<EoF 
apiVersion: v1
data:
  access_key_id: ${S3_IAM_ACCESS_KEY}
  secret_access_key: ${S3_IAM_SECRET_KEY}
  bucket_name: ${S3_NAME}
metadata:
  name: ${SEC_NAME}
type: Opaque
EoF
done

cat k8s-secret.yaml

```

## Enabling KMS Encryption


Back to the AWS IAM console, select encryption keys (it may misleadingly present a _create your first key_ page, ignore and click) and then the create button.

Select the correct region, then create key..

* Create Alias (myexample-dev-s3) and Description  (Just an example), ensure Key Material Origin is KMS 
* Define Key Administrative Permissions, give yourself permissions to delete this key for now.
* Define Key Usage Permissions, choose the IAM user in this example.
* Preview Key Policy if you wish.

Choose finish to create the key, and note the uuid for use in the stacks config below. 

Docs: http://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html




 unique _kms_ key id, (use uuidgen), add  yourself as key admin, **DO NOT** grant access to this key.

Create the bucket _**myexample-deveu-west-1**_
The secrets are avaliable to download as a csv, cache them securely.
## User name,Password,Access key ID,Secret access key





* **Add the S3 Configuration**


Most new provisioning requests are similar, try copying an exiating template in stacks/templates/hod-dsp-dev. Change the S3 key edits at the top:

```
{% set service_name = 'myexample' %}
{% set kms_id = '58855abe-2f87-4e61-9ac1-ef29b6254438' %}
{% set aws_user = service_name.upper() + '_' + env.upper() + '_S3' %}
{% set service_bucket = service_name + '-' + env + region %}
```

