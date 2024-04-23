#!/usr/bin/bash

if ! aws --version &>/dev/null; then
  echo "aws could not be found, installing"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
fi

read -r -p "Name the project: " project
read -r -p "Choose the region: " region


read -r -p "Set your AWS Key ID" AWS_KEY_ID
read -r -p "Set your AWS Access Key" AWS_ACCESS_KEY
export AWS_KEY_ID=$AWS_KEY_ID
export AWS_ACCESS_KEY=$AWS_ACCESS_KEY

aws iam delete-user \
    --user-name $project-tf-user

aws iam delete-group \
  --group-name $project-tf-group

aws dynamodb delete-table \
  --region $region \
  --table-name $project-state-lock \

aws s3 rb s3://$project-terraform-state \
  --region $region \
  --force
