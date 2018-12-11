# Kubernetes Platform Release Notes

## v0.2.14

* Refined the kubelet pod eviction policies

## v0.2.13

* Updated the kubelet pod eviction policies

## v0.2.12

* Updated to kubernetes v1.12.3

## v0.2.11

* Updating to kubernetes v1.12.1 [#PR96](https://gitlab.digital.homeoffice.gov.uk/acp/kops-acp/merge_requests/96)
* Changing to the recommended ipvs mode for the kube-proxy. [#PR98](https://gitlab.digital.homeoffice.gov.uk/acp/kops-acp/merge_requests/98)
* Added a sample psp and cluster role / binding to ease ephermal testing. [#PR96](https://gitlab.digital.homeoffice.gov.uk/acp/kops-acp/merge_requests/96)
* Update the CoreOS version to 1855.4.0 [#PR99](https://gitlab.digital.homeoffice.gov.uk/acp/kops-acp/merge_requests/99)
- Updating to Canel v3.2.3 [#PR101](https://gitlab.digital.homeoffice.gov.uk/acp/kops-acp/merge_requests/101)

## v0.2.10

* Updating the fixed version of kops
* Added the token controller for bootstrap cleanup

## v0.2.9

* Added the node authorizer to the mix [#PR87](https://gitlab.digital.homeoffice.gov.uk/acp/kops-acp/merge_requests/87)
* Fixed the s3 bucket bug [#PR92](https://gitlab.digital.homeoffice.gov.uk/acp/kops-acp/merge_requests/92)
* Fixed up the image to use the fixed node authorizer image [#PR93](https://gitlab.digital.homeoffice.gov.uk/acp/kops-acp/merge_requests/93)

## v0.2.8

* Fixed the iptables restore created by the previous release

## v0.2.7

* Allowing the blocking off vpc ssh to be optional, defaulting to true and mainly as an exception for acp-vpn

## v0.2.6

* Fixed the E2E tests. This was broken due to PSP policies which was blocking the kuberang test from running.

## v0.2.5

* Use AWS TimeSync service

## v0.2.4

* Updating the base image to alpine 3.7

## v0.2.3

* (kops release) Bumped to `custom-v0.1.3`, including a minor fix to the api-server AdmissionController flag use in k8s v1.1

## v0.2.3 (ACP Build)

- Kubernetes v1.10.3: https://github.com/kubernetes/kubernetes/releases/tag/v1.10.3

## v0.2.0 (ACP Build)

- Kubernetes v1.10.1: https://github.com/kubernetes/kubernetes/releases/tag/v1.10.1
- CoreOS v1688.5.3: https://github.com/coreos/manifest/releases/tag/v1688.5.3
- Etcd v3.3.3: https://github.com/coreos/etcd/blob/master/CHANGELOG-3.3.md#v333-2018-03-29

## v0.1.0 (ACP Build)

- Kubernetes v1.8.4: https://github.com/kubernetes/kubernetes/releases/tag/v1.8.4
- CoreOS v1632.2.1: https://github.com/coreos/manifest/releases/tag/v1632.2.1
- Etcd v3.3.1: https://github.com/coreos/etcd/blob/master/CHANGELOG-3.3.md#v331-2018-02-12
