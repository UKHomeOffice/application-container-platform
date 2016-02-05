# Developer Getting Started

## Introduction
This guide is aimed at developers that want to start using the platform to host their application.

## Initial Setup
Before you can host your application on the dsp you need to do some initial setup, the major piece will be that you will require access to OpenVPN: [OpenVPN Endpoint](https://authd.notprod.homeoffice.gov.uk).

The basic steps to start setting up a dev environment are:

 1. Request VPN access: This will require a keycloak dev-vpn / prod-vpn change for your user account to the right group.
 2. Request a namespace:
    * You may want one per environment i.e. PROJECTNAME-DEV, PROJECTNAME-PREPROD
    * Specify how much compute resources you will require i.e. 8GB / x amount of computational power
    * Specify if you require an ELB / RDS instance
 3. Request a kube token that will allow you to access the kubernetes API - the API is what you talk to deploy your application
 4. Install the [kubectl client](https://github.com/UKHomeOffice/kubernetes/releases/tag/v1.2.0-kubectl)
 5. Configure your kubectl client
 6. Add the public certificate to your list of trusted certificates

### Requesting a namespace
Many of our applications will be running on the same cluster of machines. In order to still provide separation between these applications we namespace our applications. You will need to request a namespace from the central dev ops team to get started.

To do this simply raise an issue [here](https://github.com/UKHomeOffice/dsp/issues)

### Request a token(s)
In order to have access to deploy applications on the platform you will need a token. As above this can be done by raising a github issue (preferably using the same issue for everyone in your team that needs a token). As part of this request you must specify which namespaces you need access to.

The central dev ops team will contact you to give you your token. It cannot be sent over normal chat channels due to the sensitivity of the tokens. You will need to set up [cryptocat](https://crypto.cat/) on your machine in order for your token to be sent.

### Install the [kubectl client](http://kubernetes.io/v1.0/docs/getting-started-guides/aws/kubectl.html) on your local machine
The kubectl client is required to enable you to communicate with the API server. Typically it is installed in /usr/local/bin/kubectl

### Configure the kubectl client
You will need to configure the kubectl client with the appropriate details. For help type:
```bash
kubectl config
```
You will need to set the cluster and credentials as a minimum:
```bash
export KUBE_TOKEN=xxxxx
export $NAMESPACE=mynamespace
kubectl config set-cluster dev-dsp --server=https://kube-dev-dsp.notprod.homeoffice.gov.uk
kubectl config set-credentials dev-dsp --token=$KUBE_TOKEN
kubectl config set-context dev-dsp --cluster=dev-dsp --namespace=$NAMESPACE --user=dev-dsp
kubectl config use-context dev-dsp
```
### Add the public certificate to your list of trusted CAs
The TLS certificate used for secure communication to the api server is not a publically trusted one. You will therefore need to manually tell your operating system to trust the certificate. Instructions vary between operating systems.

[ - Ubuntu](http://manpages.ubuntu.com/manpages/precise/man8/update-ca-certificates.8.html)
[ - MacOS](http://kb.kerio.com/product/kerio-connect/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html)

The certificate is:
```
-----BEGIN CERTIFICATE-----
MIID+jCCAuKgAwIBAgIIXK1YtQO7ReUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNV
BAYTAkdCMRwwGgYDVQQKExNIb21lIE9mZmljZSBEaWdpdGFsMRwwGgYDVQQLExNE
U1AgRGV2IEVudmlyb25tZW50MQ8wDQYDVQQHEwZMb25kb24xDzANBgNVBAgTBkxv
bmRvbjEbMBkGA1UEAxMSSG9tZSBPZmZpY2UgRFNQIENBMB4XDTE1MDcyMDE4MjYw
MFoXDTI1MDcxNzE4MjYwMFowgYgxCzAJBgNVBAYTAkdCMRwwGgYDVQQKExNIb21l
IE9mZmljZSBEaWdpdGFsMRwwGgYDVQQLExNEU1AgRGV2IEVudmlyb25tZW50MQ8w
DQYDVQQHEwZMb25kb24xDzANBgNVBAgTBkxvbmRvbjEbMBkGA1UEAxMSSG9tZSBP
ZmZpY2UgRFNQIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6Y2q
RJ0C2RpoK4zXbX8A13DTdmDTGRVlwy1BzYMJlA4TzQQtfkKcQc69rVFRi17XkCCq
NWaoHxxjE0/rp7l0nxcgplVuDk1VKIXlzeJuU3ia6+/QXr83yZpCQFPp+syGJFyr
21Wkck+LCtbn7R8+94G5x33Med2zh9HG3dnClveAaINTaRySeOXoDKE5KPvvFZqC
8/HPS2Beb8LTWlSPQc7tsLsu13/+KqaeumWhYqVWd1Gv+3sbKPfKpYREDeAzFzZc
EikKXZ4429CLtR7YxZAJlWhXWkl3vp0xm+AweC2Sfj2ln4yLdyb91//hbqdEBpjM
kOQdFM4DbmaZ6GQ+4QIDAQABo2YwZDAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/
BAgwBgEB/wIBAjAdBgNVHQ4EFgQUE5CNyTOmOaosn66rTP/z3X00AnkwHwYDVR0j
BBgwFoAUE5CNyTOmOaosn66rTP/z3X00AnkwDQYJKoZIhvcNAQELBQADggEBAMc9
P8B/RXDBYN5mg+y64xfn1GGkeBBaEUE7cxtXXA27gRYPyIE9pCQur7bS3Zt22kD1
wHiLQgfoNzccXq5vAGODaXYTSs5P2YgScLgLNVKFRtmAgx/hID51HV3190L9gL1R
mMIubRg343Sib8XIPBZ+88FfHfQgwNJn+qz74mZjnv/+M5hLU8qxkon1M1VBXBVb
MU5qkd8l7JvA2RbkLkalLvK9SsIMbKCxprDYckaR9GXhg5HlNQ1YGxcWGIfU+Vti
wEuacKODT7vSJvJ4a9wYpNDI00ETd2U5pPaZKIWj//W5+30sm/Hvgs06bSPOg00N
2oSUzHfbZ0x6I1Aljrs=
-----END CERTIFICATE-----
```

## Testing the setup
Run:
```bash
kubectl get pods
```
You should get an empty reply with just some column headers.
