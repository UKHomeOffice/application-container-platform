#!/bin/sh -e

if [ "${1}" = "" -o "${AWS_PROFILE}" = "" -o "${KMS_KEY_ID}" = "" ]; then 
	echo "usage: $0 <key 1>"
	exit 1
fi
if [ "${AWS_PROFILE}" = "" -o "${KMS_KEY_ID}" = "" ]; then 
	echo " Please set AWS_PROFILE and KMS_KEY_ID Enviornment variables"
	exit 2
fi

#XXX assumes the file does not already exist in which case it would overright this is not very secure
aws --profile ${AWS_PROFILE} kms encrypt --key-id ${KMS_KEY_ID} --plaintext ${1} --query CiphertextBlob --output text | base64 --decode > vault-unseal.key.encrypted
aws --profile ${AWS_PROFILE} s3 cp vault-unseal.key.encrypted s3://hod-future-dev-platform-secrets-eu-west-1
rm -f vault-unseal.key.encrypted
