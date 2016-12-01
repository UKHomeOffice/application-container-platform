# WiP
# Provisioning AWS Services into the Platform

This requires AWS credentials for hod-dsp-[env] to create the resources and dsp-ci for drone to deploy to the platform. In this example env is _dev_ and the service_name is _myexample_

## Create the S3 Bucket
Login to AWS console with profile hod-dsp-dev

Create IAM user of the format **MYEXAMPLE_DEV_S3** 

Create an AWS encryption key, for **only** type _Programmatic access_ as this is a machine account. (This user has no perms is OK)

Add a unique _kms_ key id, (use uuidgen), add  yourself as key admin, **DO NOT** grant access to this key.

Create the bucket _**myexample-deveu-west-1**_
The secrets are avaliable to download as a csv, cache them securely.



## Use our stacks provisioning container

* **Clone the repo**
```bash
$ git clone ssh://git@gitlab.digital.homeoffice.gov.uk:2222/Devops/stacks-hod-platform.git
```

* **Start the container**

Get the secrets file from the encrypted bucket and edit.
```
$ cd stacks-hod-platform
stacks-hod-platform$ git pull
stacks-hod-platform$ scripts/run.sh 
# a successful container start prompt
[root@7216efe5489b aws-dsp]#
[root@7216efe5489b aws-dsp]# fetch_secrets.sh 
retrieved the file: secrets_ci.yaml and wrote to: ./stacks/config.d/secrets_ci.yaml
[root@7216efe5489b aws-dsp]# cat ./stacks/config.d/secrets_ci.yaml
# sucessfull pulling of the secrets indicates it working
```

* **Add the S3 Configuration**


Most new provisioning requests are simple copies of a similar stacks template in stacks/templates/hod-dsp-dev. Change the S3 key edits at the top:

```
{% set service_name = 'myexample' %}
{% set kms_id = '58855abe-2f87-4e61-9ac1-ef29b6254438' %}
{% set aws_user = service_name.upper() + '_' + env.upper() + '_S3' %}
{% set service_bucket = service_name + '-' + env + region %}
```

