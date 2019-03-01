## Debug Issues with your deployments

#### Debug with secrets

Sometimes your app doesn't want to talk to an API or a DB and you've stored the credentials or just the details of that in secret.

The following approaches can be used to validate that your secret is set correctly

```bash
$ kubectl exec -ti my-pod -c my-container -- mysql -h\$DBHOST -u\$DBUSER -p\$DBPASS
## or
$ kubectl exec -ti my-pod -c my-container -- openssl verify /secrets/certificate.pem
## or
$ kubectl exec -ti my-pod -c my-container bash
## and you'll naturally have all the environment variables set and volumes mounted.
## however we recommend against outputing them to the console e.g. echo $DBHOST
## instead if you want to assert a variable is set correctly use
$ [[ -z $DBHOST ]]; echo $?
## if it returns 1 then the variable is set.
```

#### Debugging issues with your deployments to the platform

If you get to the end of the above guide but can't access your application there are a number of places something could be going wrong.
This section of the guide aims to give you some basic starting points for how to debug your application.

#### Debugging deployments

We suggest the following steps:

#### 1. Check your deployment, replicaset and pods created properly

```bash
$ kubectl get deployments
$ kubectl get rs
$ kubectl get pods
```

#### 2. Investigate potential issues with your pods (this is most likely)

If the get pods command shows that your pods aren't all running then this is likely where the issue is. You can then try curling your application to see if it is alive and responding as expected. e.g.

```bash
$ curl localhost:4000
```

You can get further details on why the pods couldn't be deployed by running:

```bash
$ kubectl describe pods *pods_name_here*
```

If your pods are running you can check they are operating as expected by `exec`ing into them (this gets you a shell on one of your containers).

```bash
$ kubectl exec -ti *pods_name_here* -c *container_name_here* /bin/sh
```

> **Please note** that the `-c` argument isn't needed if there is only one container in the pod.*

#### 3. Investigate potential issues with your service

A good way to do this is to run a container in your namespace with a bash terminal:

```bash
$ kubectl run -ti --image quay.io/ukhomeofficedigital/centos-base debugger bash
```

From this container you can then try curling your service. Your service will have a nice DNS name by default, so you can for example run:

```bash
$ curl my-service-name
```

#### 4. Investigate potential issues with ingress

Minikube runs an ingress service using nginx. It's possible to ssh into the nginx container and cat the `nginx.conf` to inspect the configuration for nginx.

In order to attach to the nginx container, you need to know the name of the container:

```shell
$ kubectl get pods
NAME                               READY     STATUS    RESTARTS   AGE
default-http-backend-2kodr         1/1       Running   1          5d
acp-hello-world-3757754181-x1kdu   1/1       Running   2          6d
ingress-3879072234-5f4uq           1/1       Running   2          5d
```

You can attach to the running container with:

```bash
$ kubectl exec -ti <ingress-3879072234-5f4uq> -c <proxy> bash
```

where `<proxy>` is the container name of the nginx proxy inside the pod. You can find the name by describing the pod.

You're inside the container. You can cat the `nginx.conf` with:

```bash
$ cat /etc/nginx/nginx.conf
```

You can also inspect the logs with:

```bash
$ kubectl logs <ingress-3879072234-5f4uq>
```
