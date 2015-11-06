
# Upgrading

This is a work in progress of how to upgrade and are mainly notes from doing this.


## Compute nodes and Infrastructure Stacks
infrastructure and compute nodes can be upgrading using the stacks update command thus


## etcd nodes
Etcd cannot just be updated in the same way as they have static volumes and static IPs. The easiest way is to delete the current stack and create a new stack. This should pickup the existing data by mounting the existing current EBS volumes

It would be wise to backup the etcd data anyway see the [etcd guide](https://coreos.com/etcd/docs/latest/admin_guide.html#backing-up-the-datastore)


