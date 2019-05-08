## Certificates

#### **Application Certificates**
-----
Before reading about certificates and how you can create and manage them. [Please familiarise yourself with our DNS naming convention first](../services/#domain-name-system-dns-pattern)

The platform provides two ways of managing [HTTPS certificates](https://en.wikipedia.org/wiki/HTTPS):
- [Internal based certificates](kube-cert-manager.md) i.e. `hostname.namespace.svc.cluster.local` using CFSSL
- [External based certificates](ingress.md) for external services i.e. `service.homeoffice.gov.uk` using kube-cert-manager and letsencrypt

In most systems, it's likely that your service will have a user facing service, that will be served through an external endpoint i.e. it can be routed to externally by users as well as having non-external facing services i.e. internal services.

You would want all communication between the user, through to the service and service dependencies to be encrypted, so that the traffic flow has encryption and that all endpoints trust who they are speaking to.

#### **Certificates**

ACP currently supports two modes for certificates, the first one legacy and being deprecated.

- [kube-cert-manager and cfssl](https://github.com/UKHomeOffice/application-container-platform/blob/master/how-to-docs/kube-cert-manager.md)
- [cert-manager](https://github.com/UKHomeOffice/application-container-platform/blob/master/how-to-docs/cert-manager.md)

#### **LetsEncrypt Limits**

Note Letsencrypt while a free service does come with a number of service limits detailed [here](https://letsencrypt.org/docs/rate-limits/). Probably one of the most crucial for projects is the max certificate requests per week; currently standing at 20. In addition, there is a max 5 failures for per hostname with a freeze of 1 hour, so if you accidently mess up configuration you might hit this.
