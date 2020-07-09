#!/bin/bash

#-----------------
# REFERENCES
#-----------------
# Script Name ::: dforc2-delete.sh
# Author      ::: RAND Corporation
#-----------------
# AWS eksctl  ::: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
#-----------------

# ------------------------------------
echo input parameters
# ------------------------------------
read -p "Input cluster name : " CLUSTERNAME
export CLUSTERNAME=$CLUSTERNAME

read -p "Input region name : " REGIONNAME
export REGIONNAME=$REGIONNAME

# ------------------------------------
echo "delete eks cluster"
# ------------------------------------ 
eksctl delete cluster --name $CLUSTERNAME --region $REGIONNAME

echo "delete cloudformation stack"
aws cloudformation delete-stack --stack-name eksctl-"$CLUSTERNAME"-cluster --region $REGIONNAME
