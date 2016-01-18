# Certificate and TLS Management

This document describes CA and TLS management implementation.

Currently, there is a CA cert/key for each environment. CAs are self-signed and
managed using [CFSSL](https://github.com/cloudflare/cfssl) tool. CA
configuration and services CSRs are stored in [ca](../ca) folder.

CA key for dev environment is checked in to git for the sake of simplicity.
However, a key for prod environment must never be checked in.

## HOWTO

Below describes steps how to create a new CA, generate and sign a new cert for
a platform service. This way of creating and distributing TLS keys should only
be used for securing platform endpoints at the platform bootstrap phase.

### Create a New CA

```
$ cfssl gencert -initca ca/dev/ca-csr.json | cfssljson -bare ca
```

### Generate a Service Cert

First of all you need to create a new CSR configuration file in json and pass
it in to cfssl tool. For example we're going to use an existing
[etcd-csr.json](../ca/etcd-csr.json) file.

```
cfssl gencert -config=ca-config.json -ca-key=ca-key.pem \
  -profile=server etcd-csr.json | cfssljson -bare etcd
```

That should produce the following files:

```
etcd-key.pem
etcd.csr
etcd.pem
```

All, but `etcd-key.pem` can be checked in to git at `ca/<environment>/` if
needed. the key file needs to be [encrypted using KMS and copied to an s3
bucket](kms.md), so that it can be securely pulled down at service start time.


## Application TLS

All internal and external application endpoints must be secured with TLS.

Vault has a support for PKI management. Our generated CA certs and keys can be
uploaded to vault directly and from that point vault becomes responsible for
issuing and signing certificates. It will never be possible to retrieve the
uploaded CA, it can only be used to sign certificates. You can read more
about how vault is implemented [here](vault.md).

Currently, there is no working example where applications running on this
platform can request a new TLS certificate to be generated and signed.


## External TLS

All incomming external traffic must go via an Amazon Elastic Load Balancer. TLS
certs/keys can be uploaded directly to an IAM service from where ELBs can fetch
them and terminate TLS. As a bonus, uploaded certs/keys cannot be retrieved
back from IAM.

