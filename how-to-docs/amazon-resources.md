# Getting Amazon resources

Amazon resources in the UK Cluster can be requested by submitting a support request on the [platform hub][support requests].

## RDS Instances

1. Log into the [Platform Hub][platform hub link].

2. Go to the [Support Requests][support requests] section and click the support request called ["Request for an RDS Instance"][rds support request].

3. Fill in the required information and submit the form. The ACP team will process your request and create the credentials required for the RDS as a secret into the namespace that you specified. You will be informed when the RDS has been created and when the secret has been created.

> Note: If you would like encryption at rest, currently the smallest instance type that supports it is `db.m3.medium`.

## S3 Buckets

1. Log into the [Platform Hub][platform hub link].

2. Go to the [Support Requests][support requests] section and click the support request called ["Request for an S3 Bucket"][s3 bucket support request]. 

3. Fill in the required information and submit the form. The ACP team will process your request and create the credentials required for the S3 bucket as a secret into the namespace that you specified. You will be informed when the S3 bucket has been created and when the secret has been created.

[support requests]: https://hub.acp.homeoffice.gov.uk/help/support/request-templates/
[platform hub link]: https://hub.acp.homeoffice.gov.uk/
[rds support request]: https://hub.acp.homeoffice.gov.uk/help/support/requests/new/rds-instance-request
[s3 bucket support request]: https://hub.acp.homeoffice.gov.uk/help/support/requests/new/s3-bucket-request
