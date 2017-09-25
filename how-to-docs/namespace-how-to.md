## How do I create a namespace in the UK cluster?
Please visit the [ACP-Kube](https://gitlab.digital.homeoffice.gov.uk/Devops/acp-kube) repo on Gitlab to create a namespace.

+ Clusters are defined by the folders within the `policies/` directory, with each cluster having a subdirectory labelled `namespaces`.

+ Namespaces should be defined in the following format within this repository:
`policies/clusters/<cluster-name>/namespaces/<namespace.yaml>`

Example namespace creation of **foo** namespace in **bar** cluster:

foo.yaml:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    name: foo
  name: foo
```
to be defined in `policies/clusters/bar/namespaces/foo.yaml`
- The name of the file must match the label defined in the yaml.
+ Clone and branch the ACP-Kube repo and create your namespace file
+ Submit a PR of your branch to master - once your PR is accepted your namespace will be created.