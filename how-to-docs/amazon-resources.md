# How to get Amazon resources in the UK cluster

Amazon resources in the UK Cluster can be requested by creating an issue on the [application-container-platform bau board](https://github.com/UKHomeOffice/application-container-platform-bau/issues)

## RDS Instances
When making your request, you should specify:
* The namespace from which your RDS will be used
* The amount of storage required
* The database type

For example:
```
Please may we have postgres 9.5 RDS with 10GB storage in the example namespace?
```

## S3 Resources
When making your request, you should specify:
* The namespace from which your bucket will be used

For example:
```
Please may we have an S3 Bucket created for use in the example namespace?
```

## Credentials
After your resources are created, your credentials will be made available in your namespace as a Kubernetes secret

