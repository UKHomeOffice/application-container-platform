# Security and disaster recovery

The Application Container Platform employs robust security principles, including but not limited to: 

- encryption of data at rest and in transit
- restricting access to resources according to operational needs
- strict authorisation requirements for all endpoints
- [role based access control](rbac.md) 

The Platform is spread across multiple availability zones, which are essentially three different data centres within a region. In case of an entire AWS region going down for a prolonged period of time, the Platform can be recreated in another region within a few hours.

The recovery of products hosted on the Platform are subject to considerations set out for the Production Ready criteria in [Service Lifecycle](service_lifecycle.md).

For further information on security and disaster recovery considerations, please raise a ticket on the [BAU Board](https://github.com/UKHomeOffice/application-container-platform-bau/issues). 
