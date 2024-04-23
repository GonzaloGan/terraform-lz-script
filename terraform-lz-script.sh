#!/usr/bin/bash

if ! aws --version &>/dev/null; then
  echo "aws could not be found, installing"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
fi

read -r -p "Name the project: " project
read -r -p "Choose the region: " region


echo "For the inital creation we need a user with privibilages for the initial resources"
echo "if you are using the root user, remember to delete the Keys"
read -r -p "Set your AWS Key ID" key_id
read -r -p "Set your AWS Access Key" access_key
export AWS_KEY_ID=$key_id
export AWS_ACCESS_KEY=$access_key
export AWS_REGION=$region

echo "A bucket will be created with the name $project-terraform-state on the region $region"
aws s3 mb s3://$project-terraform-state \
  --region $region

aws s3api put-bucket-versioning --bucket $project-terraform-state --versioning-configuration Status=Enabled


echo "A Dynamodb table will be created with the name $project-state-lock on the region $region"
aws dynamodb create-table \
  --region $region \
  --table-name $project-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1


aws iam create-group \
  --group-name $project-tf-group

aws iam attach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
  --group-name $project-group

aws iam create-user \
  --user-name $project-tf-user

aws iam add-user-to-group \
  --user-name $project-tf-user \
  --group-name $project-tf-group

aws iam create-access-key --user-name $project-tf-user > key.json

if ! jq --version &>/dev/null; then
 echo "TODO"
fi

aws configure --profile $project-terraform-profile --no-cli-auto-prompt