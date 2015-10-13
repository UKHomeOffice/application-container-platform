#!/usr/bin/bash

export ENV=dev
export AWS_PROFILE=hod-dsp
export KMS_KEY_ID=448a33c3-694b-46fe-9635-4cfecff6877a

if [[ $# != 1 ]]; then
  echo "Usage:"
  echo "  $0 decrypt"
  echo "  $0 encrypt"
fi

if [[ $1 == 'encrypt' ]]; then
  aws kms encrypt --key-id ${KMS_KEY_ID} --plaintext "$(cat auth-policy.json)" \
    --query CiphertextBlob --output text | base64 -d > auth-policy.json.encrypted
  aws kms encrypt --key-id ${KMS_KEY_ID} --plaintext "$(cat tokens.csv)" \
    --query CiphertextBlob --output text | base64 -d > tokens.csv.encrypted

  for n in $(ls -1 *.encrypted); do
    aws s3 cp ${n} s3://${ENV}-platform-secrets-eu-west-1
  done

  if [[ $? == 0 ]]; then
    rm -f tokens.csv* auth-policy.json*
  fi
fi


if [[ $1 == 'decrypt' ]]; then
  aws s3 cp s3://${ENV}-platform-secrets-eu-west-1/tokens.csv.encrypted .
  aws s3 cp s3://${ENV}-platform-secrets-eu-west-1/auth-policy.json.encrypted .

  aws kms decrypt --ciphertext-blob fileb://tokens.csv.encrypted | jq -r .Plaintext | base64 -d > tokens.csv
  aws kms decrypt --ciphertext-blob fileb://auth-policy.json.encrypted | jq -r .Plaintext | base64 -d > auth-policy.json
fi

