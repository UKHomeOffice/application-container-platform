# RBAC Groups

RBAC groups are used to control the level of access a user has to a namespace (or cluster). The RBAC groups that you need assign when creating a token will be dependant on the level of access needed for the user. Group names are created in the format: `acp:<cluster-name>:<user-type>:[cw|ns]-<role-type>:<namespace>` with `cw|ns` being cluster wide or namespace specific.

Here is an example of an RBAC group:

```yaml
acp:notprod:robot:ns-robot:hello-world
```

This indicates that this token:
* is for the `notprod` cluster
* is for a `robot` user (normal users would have `user` here instead)
* is defined for this particular `namespace`
* has a role type is `robot` which will give the user (which will most likely be a robot) that will use the token certain permissions in the namespace. Another role type is `readonly` which allows a user to list/get all of the resources in a namespace
* will be used with a namespace called `hello-world`
