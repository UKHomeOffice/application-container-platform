# Create a kubernetes pull secret for an artifactory robot account

The requester should state the namespace for the credentials.


* Create appropropriate [artifactory](https://artifactory.digital.homeoffice.gov.uk/) robot user
  and assign a temporary login password.

* Login as user and create an access token then log out.
* Deliver the token into the namespace with kubectl, example below.

* As an artifactory admin, _disble-UI-access_ for the robot user
  and **ensure this user is denied access via a browser**.


To manually test the token does function:

 `$ docker login artifactory.digital.homeoffice.gov.uk`

when using this user/token, it should be possible to pull but not push.

---
* Pass the credentials to the developer team as a [kubernetes dockercfg secret](http://kubernetes.io/docs/user-guide/kubectl/kubectl_create_secret_docker-registry/)
the following snippet describes the command:


```
DOCKER_REGISTRY_SERVER="docker.digital.homeoffice.gov.uk"
DOCKER_USER="induction-user"  # Artifactory robot user
DOCKER_PASSWORD="xxx..xxx"    # Artifactory token
DOCKER_EMAIL="joe.bloggs@digital.homeoffice.gov.uk" # not mandatory
NAME="artifactory-ro"         # kubernetes name
NAMESPACE="dev-induction"

kubectl --namespace=${NAMESPACE} create secret docker-registry ${NAME}   \
    --docker-server=${DOCKER_REGISTRY_SERVER}   \
    --docker-username=${DOCKER_USER}  \
    --docker-password=${DOCKER_PASSWORD}  \
    --docker-email=${DOCKER_EMAIL}
```

To confirm the secret is correctly in the target namespace:

```
$ kubectl namespace=dev-induction get secrets/artifactory-ro -o yaml
```
should return an object with a base64 encoded blob of the docker auth config.


