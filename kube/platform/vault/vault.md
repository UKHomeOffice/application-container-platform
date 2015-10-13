#### **Vault Kubernetes**
---

Although we could create an internal ELB for to balance the requests to Vault, given Kubernetes already
provides us with one, in the form of kube-proxy we might as well use that. So internally the vault service is provided to pods via a headless Kubernetes service.

The two files responsibility for setting up the service is: vault-svc and vault-endpoints.

##### **Create the internal vault service**

```shell
# create the namespace for the vault service
[jest@starfury vault]$ kubectl create -f vault-ns.yml
# create the headless service
[jest@starfury vault]$ kubectl --namespace=NAMESPACE create -f vault-svc.yml
# create the Endpoints
[jest@starfury vault]$ kubectl --namespace=NAMESPACE create -f vault-endpoints.yml
```

The vault service should now be available via the name: vault.NAMESPACE.cluster.local:8200 (naturally, i'm assuming you have setup dns on k8s)

##### **External Vault Access**

When running the Vault service is HA mode, the standby nodes inform the vault client of the leader via 307 http redirect. The problem with this being if it's hidden behind a ELB, the advertised leader address will be an internal LAN address and thus inaccessible. In order to get around the problem an Nginx proxy is placed in-front of the vault service (running as a k8s service/pod) as a reverse proxy.

**Requirements**

* You need to add the platform_tls certs i.e. production certs, wildcard.notprod.homeoffice.gov.uk into vault as a secret, using 'certificate' and 'private_key'

```shell
[jest@starfury vault]$ cat platform_tls.json
{ "certificate": "CERT", "private_key": "KEY" }
[jest@starfury vault]$ vault write secret/platform_tls "@platform_tls.json"
```

* You need to setup the userpass credentials for the vault-sidekick to speak to Vault.

```shell
[jest@starfury vault]$ cat vault-access.yml
---
apiVersion: v1
kind: Secret
metadata:
  name: vault
  namespace: services
data:
  vault-token.yml: |
    method: userpass
    username: services
    password: VAULT_PASSWORD
[jest@starfury vault]$ bin/encode_secrets -m vault-access.yml | kubectl --namespace=NAMESPACE -f create -f -
```

You should now have a Vault service available; running internally on CLUSTER_IP:443 and on the NodePort: 32701. You can now build the ELB via the usual method

```shell
[jest@starfury vault]$ kubectl --namespace=services get services/vault-proxy
NAME          LABELS             SELECTOR           IP(S)           PORT(S)
vault-proxy   name=vault-proxy   name=vault-proxy   10.101.238.65   443/TCP
``` 
