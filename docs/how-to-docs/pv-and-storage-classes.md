## Provisioned Volumes and Storage Classes

In order to use volumes with your pod, we use kubernetes provisioned volume claims and storage classes, to read more about this please see [Kubernetes Dynamic Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/).

On each cluster in ACP, we have the the following storage classes for you to use:

```
gp2-encrypted
gp2-encrypted-eu-west-2a
gp2-encrypted-eu-west-2b
gp2-encrypted-eu-west-2c
io1-encrypted-eu-west-2
io1-encrypted-eu-west-2a
io1-encrypted-eu-west-2b
io1-encrypted-eu-west-2c
st1-encrypted-eu-west-2
st1-encrypted-eu-west-2a
st1-encrypted-eu-west-2b
st1-encrypted-eu-west-2c
```

The `io1-*` (provisioned iops) storage classes have `iopsPerGB: "50"`

#### Backups for EBS

Once the ebs has been created, if you'd like to enable EBS snapshots for backups, please raise a ticket via the [BAU support](https://github.com/UKHomeOffice/application-container-platform-bau) so that we can add AWS tags to the volume, which will be picked up by [ebs-snapshot](https://github.com/UKHomeOffice/docker-ebs-snapshot). Please remember to specify the retention policy in days to keep the snapshots for.
