# Logging
Our logging is done via the ELK stack (Elasticsearch, Logstash, Kibana).

## Logstash
We have a logstash container that we run on all our CoreOS nodes, it sends all container and systemd logs to Elasticsearch. The container can be found [here](https://github.com/UKHomeOffice/docker-logstash-kubernetes).

## Elasticsearch
We have an Elasticsearch cluster running in the ops cluster which all logs are sent to. They are all running our Elasticsearch container which can be found [here](https://github.com/UKHomeOffice/docker-elasticsearch).

## Kibana
All logs are sent through to [Kibana](https://kibana.acp.homeoffice.gov.uk) where they can be viewed and filtered. Kibana is ran using our [kibana container](https://github.com/UKHomeOffice/docker-kibana).

### Log Retention Policy
- Logs are searchable within kibana for 5 days and remain within elasticsearch for 12 days.
- Snapshots of logs are stored within s3 indefinitely and migrated to the infrequent access storage class and then glacier storage after 60 and 180 days respectively.
- The same policy is applied to all logs within ELK
