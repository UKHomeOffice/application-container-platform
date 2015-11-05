#!/usr/bin/env bash

set -e

PUSH_SCRIPTS_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export KMS_KEY_ID=$2
export ENV=$1
source ${PUSH_SCRIPTS_HOME}/scripts.cfg

if [ "$1" == "" ]; then
    echo "expecting an environment name..."
    exit 1
fi
ENV=$1
shift
if [ "$1" == "" ]; then
    echo "expecting a KMS key ID..."
    exit 1
fi
KMS_KEY_ID=$1
shift
if [ "$1" == "" ]; then
    echo "expecting a list of files..."
    exit 1
fi
FILES=$@

for file in ${FILES} ; do

    aws kms encrypt --key-id $KMS_KEY_ID  \
      --plaintext "$(cat $file)" \
      --query CiphertextBlob \
      --output text | base64 --decode > $file.encrypted

    aws s3 cp $file.encrypted s3://${ENV}-${CLUSTER_NAME}-${REGION}-secrets/$file.encrypted
done
