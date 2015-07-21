# etcd

Digital Services Platform itself depends on a distributed key value store -
etcd. It runs on one of the clusters in its own separate set of subnets spread
across 3 availability zones.

Currently, only fleet, flannel, kubernetes API and vault can communicate to
etcd. DSP services, like BRP, are not able to reach etcd, because of firewall
restrictions.

Etcd cluster itself cannot talk to compute cluster at all.

In the future, when etcd authentication API stabilizes, we will be able to
secure it even more.

## High Availability

Current configuration has 5 EC2 instances. GIven a distributed nature of etcd,
there must be a quorum, in our case, at leat of 3 nodes. This setup allows us
to lose up to 2 etcd nodes and still have a quorum.

