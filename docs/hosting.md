# Hosting

## AWS
We host all of our services and infrastructure in AWS. We have five main accounts: notProd, CI, OPS, VPN and Prod. Access is managed through a central account called Hod-Central which can be used to assume role into each of the other accounts. This is all managed through the [Hoddat-iam repo](https://gitlab.digital.homeoffice.gov.uk/Devops/hoddat-iam). Our environments are managed using [stacks](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacks.html), each account having its own related repo. To see how notProd and Prod are set up refer to [stacks-hod-platform repo](https://gitlab.digital.homeoffice.gov.uk/Devops/stacks-hod-platform).

## Kubernetes
Each of our main AWS accounts has a Kubernetes cluster running on CoreOS within it.

We deploy the majority of our services through Kubernetes and all applications by developers should be containerised and deployed in this manner.

Tokens are needed for each of our clusters that you require access to.

Each project should have it's own namespace to deploy into, these can be created by doing a PR to our [kube-hod-platform](https://gitlab.digital.homeoffice.gov.uk/Devops/kube-hod-platform) repo.

More information on Kubernetes can be found at their [site](http://kubernetes.io) as well as our [guide](https://github.com/UKHomeOffice/application-container-platform/blob/master/developer-docs/dev_setup.md).
