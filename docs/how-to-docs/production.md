## Production <a name="production"></a>

Using production & setting up production is slightly different to the not-prod cluster, these are the steps:

  1. [Set up a prod token](#prod-token)
  2. [add the cluster to your kube file](#add-token)
  3. [add the token to your kube file](#prod-cluster)
  4. [connect to the prod vpn](#prod-vpn)
  5. [drone](#prod-drone)

### Set up a prod token <a name="prod-token"></a>

The following steps in this section can only be done by an administrator
* Go to the [platformhub](https://hub.acp.homeoffice.gov.uk)
* Click projects -> modern slavery -> details
* Scroll to the top and click on `KUBE USER TOKENS`
* And then search for your name in the drop-down
* And then click `create a new kubernetes user token for this user`
* Add the user as read-only
* Escalate priveledges to two hours, you'll need to do this everytime you are on.  If you're not an administrator then you'll have to ask your admin

### Add the user token to your kube file <a name="add-token"></a>

* Copy the token you generated above
* Go to your kube config file, usually located in `~./kube/config`
* Add the following to your users

```
  users:
  - name: acp-prod
    user:
      token: xxxxx
```

* add a context to your config like so

```
- context:
    cluster: acp-prod
    namespace: ms-prod
    user: acp-prod
  name: ms-prod
```

### Add the cluster to your kube file too <a name="prod-cluster"></a>

* Go to the [platformhub identities](https://hub.acp.homeoffice.gov.uk/identities)
* Click on `VIEW TOKENS`
* Next to the project/cluster, click on `SET UP KUBE CONFIG`
* Copy the commands and paste it on your terminal.  Your kube file should something like this

```
  apiVersion: v1
  clusters:
    name: acp-notprod
  - cluster:
      certificate-authority-data: xxxx
      server: xxx
    name: acp-prod
```
### Production vpn <a name="prod-vpn"></a>

Now connect to the acp-prod vpn.  If you can't see access you'll need to raise a ticket with ACP
https://support.acp.homeoffice.gov.uk/servicedesk/customer/portal/1/create/90

Now you should be able to use kubectl like normal.  Remember to escalate your priviledges.  If you are not admin, you'll have to ask your administrator to escalate it for you

### Production- Drone deployment <a name="prod-drone"></a>

Setting up deployments as the same as deployment in not-prod but you need to add a robot and give it priviledges.

[Add a robot](https://github.com/UKHomeOffice/application-container-platform/blob/master/docs/how-to-docs/kubernetes-robot-token.md)
