# Service Lifecycle

This defines the current service lifecycle stages. This isn't specific to the hosting platform
and will no doubt move to somewhere more organistionally wide. However, this is a starting
point to clearly communicate the phases of our evolution.

## Alpha

Alpha is an experimental phase to test the hypothesis, by building prototypes to validate
the direction and the intention of the service. It is there to explore ways of achieving and meeting
the user needs in the right way.

There is more information on this [here](https://www.dta.gov.au/standard/service-design-and-delivery-process/) and
[here](http://ausdto.github.io/service-handbook/alpha/1-introduction/1-1-what.html)

## Beta

This is the phase where software is more feature complete. It is aimed at being functional and meeting the definition
of a Minimal Viable Product, (MVP). The service is accessible and secured and meets a lot of the production requirements and needs.
However, there will be an assessment of the service through closed user groups, to evaluate that it meets the user needs.
SLA's, SLO's and availability may not meet the user expectation of a live service.

## Live

Once the products have gone through the beta process, (which is to identify that the MVP is viable), the service will transition to live.
In live, we are happy that the service has undergone enough evaluation to meet user expectations as well as being able to commit confidentially to SLA's and SLO's.  

## Production-Ready Criteria

To define what it means to be "production-ready", there is a set of criteria by which we assess services. This is not a concrete
list and is likely to evolve. We would expect Beta and Live services to adhere to this criteria list, however, it is possible that a beta may decide that
some are not necessary, depending on the size of the user group and the communication to said group.

Generally speaking, it is best not to rely or depend on a Beta service.

- Resilient (Recover from Restart)
- Highly available (Multiple Instances)
- Backups of all data
- Validation of backup, (not 0 file size)
- Restores of data tested
- CI Release process
- Continuous deployment (if needed) to prod, (done via CI)
- Is it independent of itself i.e. it doesn't rely on itself
- Tests defined and ran as part of CI process
- Monitoring of product
- Does it have an ATO?
- Monitoring Dashboards produced
- Alerting in place and tested
- Patching Process Defined + Tested
- Intrusion detection in place
- Security tested
- Does it log adequately?
- Logs persisted
- Non root user if docker is used
- Readonly root filesystem and hardening of container
- Documentation in place and standards
- Default Admin Password Changed
- Dev instance / playground
- SSO where needed
- Change Management process defined
- Incident Management process defined (incl agreed SLAs)
- Monitoring of cert expiry
