# Logging And Monitoring

## Logging

ELB access logs go to to an S3 bucket. Application and platform services logs
go to standard output which is then captured by docker and available in system
journal or can be accessed via kubernetes API.

In addition, kubernetes logs can be pushed to Cloudwatch Logs.

## Monitoring

There is basic monitoring in place. The platform itself needs to have much more
sophisticated monitoring in place as well as provide some monitoring services
to services like DSP.

DSP design with the help of Kubernetes, fleet and AWS, provides us with a huge
amount of self-healing system capabilities, that of course does not imply that
we do not need monitoring.

