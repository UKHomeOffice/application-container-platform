# How to define a new RBAC policy

Visit and clone the [acp-kube-rbac][acp kube rbac repo link] repo on GitLab.

Create a new branch for your new policy and follow the instructions on the README in the repo.

Documentation that can help write an RBAC policy can be found here: [RBAC Authorization][rbac docs].

**Note: The docs linked above are only for reference.**

Also note the `rules` section of the policies in the GitLab repo are different to the ones that are in the linked docs. Each `apiGroup`/`resource`/`verb` is on its own line with a hyphen:

[_policies/common/cluster-read-all.yaml_][cluster-read-all link]:
```yaml
...
apiGroups:
 - ""
 - apps
 - autoscaling
 - batch
 - extensions
 - policy
 - rbac.authorization.k8s.io
resources:
 - componentstatuses
 - configmaps
 - daemonsets
 - deployments
 - events
...
```

Once you have created your new policy, push the new branch and create a pull request for it. You can ask someone to review your PR by posting it in the _#devops_ slack channel.

[acp kube rbac repo link]: https://gitlab.digital.homeoffice.gov.uk/Devops/acp-kube-rbac
[rbac docs]: https://kubernetes.io/docs/admin/authorization/rbac/
[cluster-read-all link]: https://gitlab.digital.homeoffice.gov.uk/Devops/acp-kube-rbac/blob/master/policies/common/cluster-role-read-all.yaml
