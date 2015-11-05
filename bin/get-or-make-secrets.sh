#!/usr/bin/env bash
# TODO: This needs to check if the secret exists in S3 and NOT generate if it exists...
#       To refresh a secret, a -f option and file name must be specified.

set -e

export SCRIPTS_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export KMS_KEY_ID=$2
export ENV=$1
source ${SCRIPTS_HOME}/scripts.cfg

function make_certs() {
  dir_name=$1
  cert_file_name=${2:-${dir_name}}
  mkdir -p ${dir_name}

  echo "Generating the cert for ${dir_name}..."
  cfssl gencert \
    -ca=./platform/platform_ca.pem \
    -ca-key=./platform/platform_ca-key.pem \
    -config=../ca-config.json \
    -profile=server \
    ../${dir_name}-csr.json | cfssljson -bare ./${dir_name}/${dir_name}

  echo "Encrypting the certs for ${dir_name}..."
  ${SCRIPTS_HOME}/push_secrets.sh ${ENV} ${KMS_KEY_ID} ./${dir_name}/${cert_file_name}.pem
  ${SCRIPTS_HOME}/push_secrets.sh ${ENV} ${KMS_KEY_ID} ./${dir_name}/${cert_file_name}-key.pem
}

function link_kubectl_and_upload() {

  mkdir -p $1
  cd $1
  ln -s ../kubeconfig
  cd ..
  ${SCRIPTS_HOME}/push_secrets.sh ${ENV} ${KMS_KEY_ID} ./$1/kubeconfig

}

cd ${SCRIPTS_HOME}/../secrets/

if [ ! -f ${ENV}/ca-csr.json ]; then
    echo "Missing ${ENV}/ca-csr.json, please specify environment"
    exit 1
fi
if [ "$2" == "" ]; then
    echo "expecting a KMS key ID..."
    exit 1
fi
cd ${ENV}

echo "Initialize a CA..."
cfssl gencert -initca ca-csr.json | cfssljson -bare ./platform/platform_ca
${SCRIPTS_HOME}/push_secrets.sh ${ENV} ${KMS_KEY_ID} ./platform/platform_ca.pem
${SCRIPTS_HOME}/push_secrets.sh ${ENV} ${KMS_KEY_ID} ./platform/platform_ca-key.pem

make_certs etcd
make_certs vault
make_certs apiserver kube-apiserver
${SCRIPTS_HOME}/push_secrets.sh ${ENV} ${KMS_KEY_ID} ./kube-apiserver/tokens.csv

../create_kube_config.sh
link_kubectl_and_upload kube-apiserver
link_kubectl_and_upload kube-kubelet
link_kubectl_and_upload kube-proxy
link_kubectl_and_upload kube-scheduler
