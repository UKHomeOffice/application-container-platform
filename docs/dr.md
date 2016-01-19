# Disaster Recovery

As mentioned in [platform overview](overview.md) document, the system is
automatically spread across multiple availability zones, which are essentially
3 different data centres within a region.

In case of entire AWS region (Dublin in this case) goes down for a prolonged
period of time, the platform can be recreated in another region within a few
hours.

If there is temporary glitch in the system or AWS region problem, then a static
web page is served from an S3 bucket. The switchover happens automatically at
[DNS](docs/dns.md) level.

The lack of maturity in this platform and user need, prevents us from having a
proper DR solution at this point.

