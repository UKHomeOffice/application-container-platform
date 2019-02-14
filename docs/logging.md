# Logging
Logging stack consists of [Elasticsearch](https://github.com/UKHomeOffice/docker-elasticsearch), [Logstash](https://github.com/UKHomeOffice/docker-logstash-kubernetes), [Kibana](https://github.com/UKHomeOffice/docker-kibana)).

- Logstash agents deployed as a daemonSet will collect all workload logs and index them in Elasticsearch. 
- Logs are searchable for a period of 5 days through [Kibana UI](https://kibana.acp.homeoffice.gov.uk). Access to view logs can be requested via [Support request](https://hub.acp.homeoffice.gov.uk/help/support/requests/new/kibana-access-request).


### Current Log Retention Policy

- Logs are searchable in Kibana for 5 days and remain within Elasticsearch for 10 days.
- Collected workload logs will be persisted in S3 indefinitely and migrated to the infrequent access storage class and then glacier storage after 60 and 180 days respectively. **NOTE: this may change in the future!**
- The same policy applies to all logs within ELK
