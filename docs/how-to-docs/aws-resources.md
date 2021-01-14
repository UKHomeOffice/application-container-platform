# AWS Resources

ACP supports the creation of several AWS resources such as S3 buckets, RDS instances, Redis clusters and Elasticsearch domains.

## S3 buckets

To request the creation of a s3 bucket, you can [create a ticket](https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/27).

ACP enables kms encryption on s3 buckets by default and enforces kms encryption on object uploads. In order to upload to the bucket you will need to upload using the kms key in your secret (created alongside the s3 bucket in your requested namespace).

```bash
aws s3 cp ./mytextfile.txt s3://DOC-EXAMPLE-BUCKET/ --sse aws:kms --sse-kms-key-id testkey
```
