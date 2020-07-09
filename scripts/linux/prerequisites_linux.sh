#!/bin/bash

#-----------------
# REFERENCES
#-----------------
# Script Name ::: prerequisties_windows.ps1
# Author      ::: RAND Corporation
#-----------------
# AWS eksctl  ::: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
# AWS IAM Authenticator  ::: https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
# Kubernetes  ::: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows
#-----------------

# ------------------------------------
echo input parameters 
# ------------------------------------  
export AWSACCESSKEY=$(read -p "Input AWS access key : ")
export AWSECRETACCESSKEY=$(read -p "Input AWS secret access key : ")
export REGION=$(read -p "Input AWS region : ")
# ------------------------------------
echo "install aws cli & set access keys"
# ------------------------------------
sudo apt-get install python -y
sudo apt-get install unzip -y
sudo apt-get install curl -y
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
echo "setting aws cli access keys"
aws configure set aws_access_key_id $AWSACCESSKEY
aws configure set aws_secret_access_key $AWSECRETACCESSKEY
aws configure set default.region $REGION
# ------------------------------------
echo "install kubectl command-line"
# ------------------------------------ 
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
# ------------------------------------
echo "install aws-iam-authenticator"
# ------------------------------------ 
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir $HOME/bin
cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
# ------------------------------------
echo "install eksctl command-line"
# ------------------------------------ 
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
