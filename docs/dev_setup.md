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

### Install the [kubectl client](https://github.com/UKHomeOffice/kubernetes/releases/tag/v1.2.0-kubectl) on your local machine
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
kubectl config set-cluster dev-dsp --server=https://kube-dev.dsp.notprod.homeoffice.gov.uk
kubectl config set-credentials dev-dsp --token=$KUBE_TOKEN
kubectl config set-context dev-dsp --cluster=dev-dsp --namespace=$NAMESPACE --user=dev-dsp
kubectl config use-context dev-dsp
```
### Tell kubernetes to trust the certificate authority
The TLS certificate used for secure communication to the api server is not a publically trusted one. You will therefore need to manually tell your kubernetes client to trust it.

Edit your kubernetes config (~/.kube/config) so your cluster configuration looks like:

- cluster:
    server: https://kube-dev.dsp.notprod.homeoffice.gov.uk
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURxakNDQXBTZ0F3SUJBZ0lJQnY5S29HUUVkVzR3Q3dZSktvWklodmNOQVFFTE1HTXhDekFKQmdOVkJBWVQKQWtkQ01SQXdEZ1lEVlFRS0V3ZEJWMU1nUkZOUU1Rc3dDUVlEVlFRTEV3SkRRVEVQTUEwR0ExVUVCeE1HVEc5dQpaRzl1TVE4d0RRWURWUVFJRXdaTWIyNWtiMjR4RXpBUkJnTlZCQU1UQ2tGWFV5QkVVMUFnUTBFd0hoY05NVFl3Ck1URTBNVGN5TnpBd1doY05Nall3TVRFeE1UY3lOekF3V2pCak1Rc3dDUVlEVlFRR0V3SkhRakVRTUE0R0ExVUUKQ2hNSFFWZFRJRVJUVURFTE1Ba0dBMVVFQ3hNQ1EwRXhEekFOQmdOVkJBY1RCa3h2Ym1SdmJqRVBNQTBHQTFVRQpDQk1HVEc5dVpHOXVNUk13RVFZRFZRUURFd3BCVjFNZ1JGTlFJRU5CTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGCkFBT0NBUThBTUlJQkNnS0NBUUVBdmwzY2NucWpxZmdXcUx2Z1FDTW5NRWdielJFcXJzU2xuK2xOMjByeWJ1OFgKN3VNd0VnNGpTZ0dRektnK1d1Y0FsKys2b1NoSFk5UkF1RHNreUVac2FTVUxHaW1ZMWw4YTQwNU1NWkVMOFNDUApNUkhVaEZDY2lodGZ3djNlZ1dlWm9WQmttUWY5KzZUeWVMUzkyNGo5dCtLRk1NdERxUGZNS2REUWwxTzdMUFh3CmZPN3dDYk52OU5pcFBpOWE2NWJoNVo4MGZ5eXZ4Rjh3MmpBK3BJTzMyMkJ1dDhXbERkWXlmQmQvZ2kzYzZGYWEKNTJuQmhaQVM2eE80V0lrT3gzVnpzT0tXVFd5UCtyRmpjMjlLNUIyNjZIMHlsbTB5QlBBeXdnYzFBN2U2MzVEWQpOcGQydXg3Unp5QUI2MU1nZ1hHR3Y5ZlY4WjJ1YlIvQWRJa2VtUWMvcVFJREFRQUJvMll3WkRBT0JnTlZIUThCCkFmOEVCQU1DQUFZd0VnWURWUjBUQVFIL0JBZ3dCZ0VCL3dJQkFqQWRCZ05WSFE0RUZnUVU0TXNNSGF6V1hqZzUKekp2N1c1bHZtMDNtcjY0d0h3WURWUjBqQkJnd0ZvQVU0TXNNSGF6V1hqZzV6SnY3VzVsdm0wM21yNjR3Q3dZSgpLb1pJaHZjTkFRRUxBNElCQVFBSHRHeXBIdVZZaGN5WmpNeHMzQlJ5T0ZVUWlWRkE0Zk9hZ3RjclY2WTVCeXhMCm1zVmdEbXhpYTZRcFRnUDdxazhpYmV4T25ka2FpZ2xsVS8vY1pKaGRGRENPUlVKa00wVHRuRVBoQWZFaVRGZ2oKVk9LQU1qZlE2NGlFdStIOFBwcDgrcFZhdDJDWkVsaGN4Rit5YmNBWFcxZXp1UGdvcFZzZHFMZWdYZkdRMkQ5YQoxVkorQWhVVEE3OU9tM2ZrNHNHd2htQUwxYzE1WHEvRjFEeFlRSDFZZEJGQ0g1Sk0zY25XUi9yMzZsTVdQaTRKCktuL3U5ZUo3Qk4zZHFZdGgwSUd2UWV6am1FZVJpTWN5QkdMZXZRci9zR3UwaDV4T3BvUGUyM0hOOXI1V3IrOWgKQjYwVnE3RU1mVDlYRUNIK0FvNEkwYWtFWithenBHV0R3SFJ3ZXgyNwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  name: dsp-dev


## Testing the setup
Run:
```bash
kubectl get pods
```
You should get an empty reply with just some column headers.
