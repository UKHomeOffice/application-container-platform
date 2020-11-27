

## How to perform Anchore scan in a docker build pipeline


###  Anchore Overview

Anchore Engine is an open-source Docker container static analysis and policy-based compliance tool that automates the inspection, analysis, and evaluation of images against user-defined checks to allow high confidence in container deployments by ensuring workload content meets the required criteria. Anchore Engine ultimately provides a policy evaluation result for each image: pass/fail against policies defined by the user. Additionally, the way that policies are defined and evaluated allows the policy evaluation itself to double as an audit mechanism that allows point-in-time evaluations of specific image properties and content attributes.

Anchore Uses CVE as The CVE identifier is the official way to track vulnerabilities.

The Common Vulnerabilities and Exposures (CVE) system establishes a standard for reporting and tracking vulnerabilities. CVE Identifiers are assigned to vulnerabilities to make it easier to share and track information about these issues. The identifier takes the following form: CVE-YEAR-NUMBER, for example CVE-2014-0160.




### Setup 

To setup anchore we need to go to the `drone.yml` file and we need to add two parts: a step and a service.

 1.  Add the step.

Within the steps section you will need to define a step for the anchore submission client. In this example we are working with the acp-example repository. So, when creating your own scan step, you will need to change the value of the `IMAGE_NAME` environment variable.

```YAML
steps:
- name: scan-image
  image: 340268328991.dkr.ecr.eu-west-2.amazonaws.com/acp/anchore-submission:latest
  pull: always
  environment:
    IMAGE_NAME: acp-example-app:${DRONE_COMMIT_SHA}
  when:
    event:
    - push
    - tag
```

 2. Add the service.

The anchore submission client from the `scan-image` step needs to communicate with an anchore submission server that has access to the image that needs scanning. The server is defined below:

```YAML
services:
- name: anchore-submission-server
  image: 340268328991.dkr.ecr.eu-west-2.amazonaws.com/acp/anchore-submission:latest
  pull: always
  commands:
    - /run.sh server
```
    
Here are the environment variables supported by the image used in the `scan-image` step:



 Variable                | Usage                                                                      | Default   
------------------------ | -------------------------------------------------------------------------- |------------
SERVICE_URL              | the url the anchore submission service is running on                       | http://anchore-submission-server:10080		
IMAGE_NAME	             | the name of the image you wish to have scanned	                            |n/a 
DOCKERFILE               | the path to the Dockerfile                                                 |	n/a
TOLERATE	               | the minimum level of vulnerability we are willing to tolerate              | (low, medium, high)	medium
WHITELIST	               | a collection of CVEs (allows for comma separation) we are willing to accept|	n/a
WHITELIST_FILE           | the path to a file containing a list of whitelisted CVEs                   |	n/a
FAIL_ON_DETECTION        |	indicates if we should exit with 1 if a vulnerability is found	          |true
SHOW_ALL_VULNERABILITIES |	indicates we should show all vulnerabilities regardless	                  |false
LOCAL_IMAGE              |	indicates the image is locally available	                                |false
AUTH_TOKEN               |	an authentication token used to speak to the api with	                    |n/a
TIMEOUT                  |	the max time you are willing to wait for the scan to complete (in s)	    |20 minutes

### Example of Whitelisting a CVE

If you need to whitelist a particular CVE, you will need to add the environment variable `WHITELIST` within the step shown above and add the CVE.

Here is an example for whitelisting two CVE's: CVE-2008-4318 and CVE-2020-25613.
    
    
```YAML
steps:
   - name: scan-image
  image: 340268328991.dkr.ecr.eu-west-2.amazonaws.com/acp/anchore-submission:latest
  pull: always
  environment:
    IMAGE_NAME: acp-example-app:${DRONE_COMMIT_SHA}
    WHITELIST: CVE-2008-4318,CVE-2020-25613
  when:
    event:
    - push
    - tag
```

### Bespoke anchore submission server service name

If you need to specify a different name for the Anchore submission server service (e.g. if you need to run several services because you run several pipelines concurrently), you will need to configure the scanning step to use that service with the `SERVICE_URL` environment variable.

For example:

```YAML
steps:
- name: scan-image
  image: 340268328991.dkr.ecr.eu-west-2.amazonaws.com/acp/anchore-submission:latest
  pull: always
  environment:
    IMAGE_NAME: acp-example-app:${DRONE_COMMIT_SHA}
    SERVICE_URL: http://another-anchore-submission-server:10080

services:
- name: another-anchore-submission-server
  image: 340268328991.dkr.ecr.eu-west-2.amazonaws.com/acp/anchore-submission:latest
  pull: always
  commands:
    - /run.sh server
```
