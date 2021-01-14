## AWS Resources

ACP supports the creation of several AWS resources such as S3 buckets, RDS instances, Redis clusters and Elasticsearch domains.

### S3 buckets

To request the creation of a s3 bucket, you can [create a ticket](https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/27).

ACP enables kms encryption on s3 buckets by default and enforces kms encryption on object uploads. In order to upload to the bucket you will need to upload using the kms key in your secret (created alongside the s3 bucket in your requested namespace).

```bash
aws s3 cp ./mytextfile.txt s3://DOC-EXAMPLE-BUCKET/ --sse aws:kms --sse-kms-key-id testkey
```

### Elasticache

Some redis clients aren't compatible with different types of redis clusters (for example, redis-py is not compatible with a redis cluster which has cluster mode enabled). You can investigate which redis client is best for your use case by using the [Redis client page](https://redis.io/clients)

A possible choice for connecting to a redis cluster with cluster mode enabled and ssl enabled is the [redis-py-cluser](https://pypi.org/project/redis-py-cluster/). Below is a example of connecting to a password proctected redis elasticache cluster:

```py
from rediscluster import RedisCluster

rc = RedisCluster(
    host='clustercfg.cfg-endpoint-name.aq25ta.euw1.cache.amazonaws.com',
    port=6379,
    password='password_is_protected',
    skip_full_coverage_check=True,  # Bypass Redis CONFIG call to elasticache 
    decode_responses=True,          # decode_responses must be set to True when used with python3
    ssl=True,                       # in-transit encryption, https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/in-transit-encryption.html 
    ssl_cert_reqs=None              # see https://github.com/andymccurdy/redis-py#ssl-connections
)

rc.set("foo", "bar")

print(rc.get("foo"))
```

For more examples using the redis-py-cluster package you can navigate to the [Examples folder](https://github.com/Grokzen/redis-py-cluster/tree/master/examples) in the packages Github repo.