# Applications and Services Deployment

One of nicest features of this platform is that it provides us with a
unified Kubernetes API, which allows us to compose, deploy, and scale
services and applications running on this platform. That is all that a
developer needs to know, except when a service needs to be exposed to the
outside world (see below).

This documents does not aim to document how Kubernetes API works and how to
interact with it, there is a lot of documentation available
[here](https://github.com/GoogleCloudPlatform/kubernetes/tree/master/docs).


## External Services

Public facing applications require an ELB created via the stacks tool. You may
noticed that in [coreos-compute template](../stacks/templates/coreos-compute.yaml)
there are no ELBs defined.  It is quite common to create a load balancer within
the same CloudFormation stack and attach it directly to an auto scaling group
during its creation.  While this approach is quite simple to do, it is not the
most reliable, because an ASG + LaunchConfiguration is an immutable object,
therefore any changes to an ELB resource during stack update terminates all
instances at once and recreates them and the ELB.

A better way of adding an ELB to an auto scaling group in which our CoreOS
compute nodes live, is to create an ELB in a separate stack template and then
attach it to the auto scaling group via AWS API.

Kubernetes has a basic support for AWS Cloud, can create an ELB and attached it
to compute instances, but that needs more testing and it is very limited at the
moment.

### Node Ports

These ELBs map to NodePorts on the node. As a limited resource please state what 
range you want to be assigned to your application. The currently assigned ranges 
are

 Application  | Ports
--------------|------------
BRP           | 30000-30099 
BRP Mock API  | 30100-30199
API Catalogue | 30300-30399   
OTM           | 30400-30499
SRRS          | 30500-30599
PLATFORM      | 32700-32799

Please create a new pull request to request a range.

## Example Deployment

Since BRP is the first resident to run on this platform, we are going to use it
as an example. Instructions below assume that you have a correctly configured
`kubectl` client and can talk to kubernetes cluster.

Currently, BRP services definition files live in [the kube](../kube) folder of
this repo.

### BRP Application Needs Redis

```bash
$ kubectl create -f kube/brp-redis-controller.yaml
replicationcontrollers/brp-redis

$ kubectl create -f kube/brp-redis-service.yaml
services/brp-redis
```

### Deploy BRP Application Itself

```bash
$ kubectl create -f kube/brpapp-controller.yaml
replicationcontrollers/brpapp

$ kubectl create -f kube/brpapp-service.yaml
```

### Create an ELB for BRP

BRP is an external service, which requires a load balancer in front of it,
we're going to create it with a stacks template.

```bash
$ stacks -p hod-dsp create -e dev -t templates/brp.yaml dev-brp
```

Remember, by default the ELB does not get attached to any auto scaling group,
but it is very easy to do that using aws cli.

* **Let's find an ID for our newly created ELB first**

```bash
$ aws --profile hod-dsp elb \
  describe-load-balancers | jq .LoadBalancerDescriptions[].LoadBalancerName

"dev-brp-BRPELB-IU7XN24U7CVI"
```

* **Next, we need to find compute ASG**

```bash
aws --profile hod-dsp autoscaling \
  describe-auto-scaling-groups | jq .AutoScalingGroups[].AutoScalingGroupName

"dev-coreos-compute-CoreOSComputeScalingGroup-MW0AEFC467S"
```

* **And finally attach the ELB**

```bash
aws --profile hod-dsp autoscaling attach-load-balancers \
  --auto-scaling-group-name dev-coreos-compute-CoreOSComputeScalingGroup-MW0AEFC467S \
  --load-balancer-names dev-brp-BRPELB-IU7XN24U7CVI
```

