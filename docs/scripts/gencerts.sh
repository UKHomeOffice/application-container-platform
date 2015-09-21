#!/bin/sh -e

CERTS="kube-apiserver-csr.json vault-csr.json etcd-csr.json"

# XXX doest test bucket exists
# very buggy 
if [ "${AWS_PROFILE}" = "" -o "${ENV}" = ""]; then
	echo "AWS_PROFILE and ENV env vars should be set"
	exit 1
fi

if [ ! -e ./ca-config.json ]; then
	echo "Must be ran in the ca directory. Where ca-config.json is"
	exit 2
fi

if [ ! -e ${ENV}/ca-key.pem ]; then 
	echo "${ENV}/ca-key.pem and ${ENV}/ca.pem should be th elocation of your ca certs@
	exit 3
fi

for CERT in ${CERTS}; do 
	NAME=`echo ${CERT} | sed -e 's/-csr.json//'`
        cfssl gencert -config=./ca-config.json -ca-key=${ENV}/ca-key.pem -ca=${ENV}/ca.pem -profile=server ${CERT} | cfssljson -bare ${NAME}
        # XXX this should be a function
	aws --profile ${AWS_PROFILE} kms encrypt --key-id ${KMS_KEY_ID} --plaintext "`cat ${NAME}.pem`" --query CiphertextBlob --output text | base64 --decode > ${NAME}-crt.pem.encrypted
	aws --profile ${AWS_PROFILE} kms encrypt --key-id ${KMS_KEY_ID} --plaintext "`cat ${NAME}-key.pem`" --query CiphertextBlob --output text | base64 --decode > ${NAME}-key.pem.encrypted
	rm  ${NAME}-key.pem ${NAME}.pem
done 


# XXX this should be a function
aws --profile ${AWS_PROFILE} kms encrypt --key-id ${KMS_KEY_ID} --plaintext "`cat kubeconfig`" --query CiphertextBlob --output text | base64 --decode > kubeconfig.encrypted
ls -l kubeconfig.encrypted
echo "Generateing tokens.csv encrypting and uploading"
aws --profile ${AWS_PROFILE} kms encrypt --key-id ${KMS_KEY_ID} --plaintext "$(echo ${KUBE_TOKEN},kube,kube)" --query CiphertextBlob --output text | base64 --decode > tokens.csv.encrypted
echo " encrypting auth-policy.json and uploading "
aws --profile ${AWS_PROFILE} kms encrypt --key-id ${KMS_KEY_ID} --plaintext "`cat auth-policy.json`" --query CiphertextBlob --output text | base64 --decode > auth-policy.json.encrypted


for n in $(ls -1 *.encrypted); do
  aws --profile ${AWS_PROFILE} s3 cp ${n} s3://${ENV}-platform-secrets-eu-west-1
  rm ${n}
done
