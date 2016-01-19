# Logging And Monitoring

## Logging

ELB access logs go to to an S3 bucket. Application and platform services logs
go to standard output which is then captured by docker and available in system
journal or can be accessed via kubernetes API.


### CoreOS

TODO


### Kubernetes Containers
Kubernetes logs can be pushed to Cloudwatch Logs. See [platform setup
document](platform_setup.md) for how to set it up.

Logstash tails docker logs and extracts `pod`, `container_name`, `namespace`,
etc. The way this works is very simple. Logstash looks at an event field which
contains full path to kubelet created symlinks to docker container logs, and
extracts useful information from a symlink name. No access to Kubernetes API
is required.

Events are then pushed to Cloudwatch logs. An example event in Cloudwatch Logs
looks like below:

```json
{
    "log": "10.10.112.0 - - [02/Oct/2015:15:20:38 +0000] \"GET /dataset HTTP/1.1\" 200 2 \"-\" \"axios/0.5.4\" 6\n",
    "stream": "stdout",
    "time": "2015-10-02T15:20:38.706043658Z",
    "replication_controller": "data-assurance-api",
    "pod": "data-assurance-api-p82sy",
    "namespace": "hoapi-catalogue",
    "container_name": "data-assurance-api",
    "container_id": "df1874255f0c85d18747b5edfc8dc372dbebf725b9ccbfb37549f5f81bba8326"
}
```

## Monitoring

There is basic monitoring in place. The platform itself needs to have much more
sophisticated monitoring in place as well as provide some monitoring services
to services like DSP.

DSP design with the help of Kubernetes, fleet and AWS, provides us with a huge
amount of self-healing system capabilities, that of course does not imply that
we do not need monitoring.

