# Provisioning an AWS RDS database into the Platform

This requires docker and AWS credentials for hod-dsp-[env] to create the resources and dsp-ci for drone to deploy to the platform. In this example env is _dev_ and the service_name is _myexample_


### Workflow
 - Pull stacks-hod-platform repo
 - Configure templates in feature branch
 - Create db password and upload secrets and push
 - Peer review then merge to master, optionally run script to deploy to prod
 - Pass access to requester as kubernetes secrets


### Source the current configs by git pulling the stacks repo

`$ git clone ssh://git@gitlab.digital.homeoffice.gov.uk:2222/Devops/stacks-hod-platform.git`

### Configure by editing files

* make feature branch and enter the appropriate dev/prod directory.
  Find templates 
  
  `$ ls stacks-hod-platform/stacks/templates/hod-dsp-*`

* RDS: copy a similar existing template based on the db type (postgres/mysql or other).
  Change the lines at the top defining the resource name, this example satisfies the request of the name _egteam_ in the prod environment. Other changes may be required such as TCP Port etc.
  
```
{% set service_name='egteam' %}
{% set service_env='prod' %}
{% set dns_name=service_name+'-'+service_env %}
# the resource name constructed like: {{ service_name }}-{{ service_env }}-rds
```
This will be visible in the deployed AWS resource as DBSubnetGroupName": "egteam-prod-rds-..."

  - Change the instance type and database size according to the request
    `AllocatedStorage: 100`
    `DBInstanceClass: db.m3.large`

  - Name password variable appropriately and ensure service not tagged public
    `MasterUserPassword: {{ egteam_prod_rds_root_password }}`
    `PubliclyAccessible: false`

  - Create and add a secret for the `egteam_prod_rds_root_password` 
    - `$ scripts/run.sh` run the container
    - `$ assume_role` to ensure correct AWS privilages
    - `$ fetch_secrets` populate the secrets files 

      then edit `stacks-hod-platform/stacks/config.d/secrets_ci.yaml`
      and add a new entry to match egteam_prod_rds_root_password with a strong password.
    
      _(Genenerate one with `$ openssl rand -base64 32`)_
    
      Upload the modified secrets files into the environment with
      
      `$ upload_secrets.sh`
    
  - Then commit and push feature branch. Watch CI for validation issues.
 
  - If CI passed, create MR (delete branch when merged) and await peer review.

  - Once MR is approved, accept merge into master youself (delete feature branch on merge) and watch CI.
    Note delay for RDS creation which may cause a deploy failure, if so repeat the drone build.


### Deploying to Production

By default, the push to master will deploy to the dev environment. 
Deploying to prod will require your drone environment variables to be exported.

  - From the repo, run `scripts/deploy_env.sh -e prod` which starts a container.
  - Watch the CI for issues (it is possible delayed RDS creation may indicate failure but suceed).


## Inform the requester of access details

The CI will have created the resource on AWS and be visible from the console. Identify the correct RDS resource and populate the kubernetes secret with the corrent values.

  - List all the RDS instances for the environment
    
    ```
    aws --profile hod-dsp-[env] rds describe-db-instances > rds.json  # cache the full list
    cat rds.json | egrep "DBSubnetGroupName|\"DBInstanceIdentifier"  # identify resource in list
    ```
    Extract only the required resource
    ```
    aws --profile hod-dsp-prod rds describe-db-instances \
         --db-instance-identifier <DBInstanceIdentifier>  > rds.json` # extract a single resource if you wish
    ```
  
    
The example script below populates a kubernetes secret with the first RDS resource in the json. Optionally by supplying an index value, as argument 2 to the script, the full RDS json list may be read.

The first argument to the script is the database password generated above.
    

```
#!/bin/bash

# Usage:  ./script <db-passwd> <Index>

[[ "$2" ]] && Index="$2" || Index=0  # show the first resource by default


function extract { ## extract the resource values from the json
  jq -r '@sh  "
AvailabilityZone=\(.DBInstances['"$Index"'].AvailabilityZone)   
InstanceCreateTime=\(.DBInstances['"$Index"'].InstanceCreateTime)
Engine=\(.DBInstances['"$Index"'].Engine)
DbiResourceId=\(.DBInstances['"$Index"'].DbiResourceId)
AllocatedStorage=\(.DBInstances['"$Index"'].AllocatedStorage)
DBName=\(.DBInstances['"$Index"'].DBName)
DBInstanceClass=\(.DBInstances['"$Index"'].DBInstanceClass)
Endpoint=\(.DBInstances['"$Index"'].Endpoint.Address)
Port=\(.DBInstances['"$Index"'].Endpoint.Port)
MasterUsername=\(.DBInstances['"$Index"'].MasterUsername)"'  \
  rds.json
}

. <(extract)

cat - << EoF
apiVersion: v1
data:
  database_name: $(echo -n ${DBName} | base64)
  endpoint: $(echo -n ${Endpoint} | base64)
  id: $(echo -n ${DbiResourceId} | base64)
  password: $(echo -n "${1}" | base64)
  port: $(echo -n ${Port} | base64)
  username: $(echo -n ${MasterUsername} | base64)
kind: Secret
metadata:
  name: ${DBName}-rds-access
type: Opaque
EoF

```
