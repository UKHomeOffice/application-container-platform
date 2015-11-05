#!/usr/bin/env bash
echo "Generate the kubectl config..."

# Generate a token
TOKEN=$(uuidgen)
cat > kubeconfig <<-CONFIG
apiVersion: v1
kind: Config
preferences: {}
contexts:
- context:
    user: nfidd
  name: default
current-context: default
users:
- name: nfidd
  user:
    token: ${TOKEN}
CONFIG

mkdir -p ./node-register
echo "${TOKEN},${CLUSTER_NAME},${CLUSTER_NAME}" > ./kube-scheduler/tokens.csv
echo "${TOKEN}" > ./node-register/node-register.token
cd ./kube-apiserver/
ln -s ../kube-scheduler/tokens.csv
