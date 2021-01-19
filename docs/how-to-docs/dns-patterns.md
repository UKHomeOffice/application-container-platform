## DNS Patterns

To provide a consistent way both for services route their application traffic to the appropriate hosting platforms, and for ACP to utilise DNS, we use naming conventions for DNS across services.

If you require TLS certificates for a service, ensure you are aware of the rate limits on certificates and Let’s Encrypt. For more information on rate limits, see the [Let’s Encrypt documentation](https://letsencrypt.org/docs/rate-limits/).

If you require a service.gov.uk subdomain, you need to liaise with the Government Digital Service (GDS) and have them delegate it to the ACP team’s control.

Note that due to the limitations on CNAME records, we cannot point the apex of a delegated domain to our ingress controllers. You cannot host domains that use a service.gov.uk subdomain instead of homeoffice.gov.uk on ACP. Instead, you need to use a subdomain.  

For example, example.service.gov.uk does not work, but www.example.service.gov.uk does.


###For Non-Production Services

Define new service URLs in the following format:

<servicename>.<env>.<service>-notprod.homeoffice.gov.uk

Where:

<servicename>: The name of the service users or other services will consume (for example, web-portal)

<env>: The service environment (for example, dev)

<service>: The overall service name or project name (for example, example-service)

An example non-production service URL is as follows:


web-portal.dev.example-service-notprod.homeoffice.gov.uk



###For Production Services

To protect production services from hitting limits, and to distinguish them from non-production services, we use the main service name as the domain for them:

<servicename>.<service>.homeoffice.gov.uk

Where:

<servicename>: The name of the service users or other services will consume (for example, web-portal)

<service>: The overall service name or project name (for example, example-service)

An example production service URL is as follows:

service.homeoffice.gov.uk
