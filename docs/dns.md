# Domain Name System (DNS) Pattern

To standardise on how services route their application traffic to the appropriate hosting platform and to offer consistency in how we approach DNS we have a standard DNS naming convention for services.

In parallel to this, users need to also be aware of [the limits on certificates and letsencrypt](../how-to-docs/certificates.md) if they are wanting external TLS certificates for their services.

### For Non-production Services

The following categories are something we would expect a service to specify:

`Service Name` - The name of the service users or other services will attempt to consume i.e. `web-portal`

`Env` - The environment of the service i.e. `Dev`

`Service` - The overall service name or project name i.e. `example-service`

```
<servicename>.<env>.<service>-notprod.homeoffice.gov.uk

web-portal.dev.example-service-notprod.homeoffice.gov.uk
```


### For Production Services

As we want to protect production services from hitting limits and to create a distinction between services that are non-production, (not prod)  and production, we simplify the overall approach by using the main service name as the domain.

`Service Name` - The name of the service users or other services will attempt to consume i.e. `web-portal`

`Service` - The overall service name or project name i.e. `example-service`

```
<servicename>.<service>.homeoffice.gov.uk

web-portal.example-service.homeoffice.gov.uk
```
