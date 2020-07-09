#!/bin/bash

#-----------------
# REFERENCES
#-----------------
# Script Name ::: dforc2-deploy.sh
# Author      ::: RAND Corporation
#-----------------
# AWS eksctl  ::: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
#-----------------

# ------------------------------------
echo "input parameters"
# ------------------------------------
read -p "Input cluster name : " CLUSTERNAME
export CLUSTERNAME=$CLUSTERNAME
read -p "Input node worker group name e.g. desh-workers : " NODEGROUPNAME
export NODEGROUPNAME=$NODEGROUPNAME
read -p "Input AWS region : " REGION
export REGION=$REGION
read -p "Input EC2 instance type e.g. t3.medium : " NODETYPE
export NODETYPE=$NODETYPE
read -p "Input total nodes to deploy e.g. 3 : " NODES
export NODES=$NODES
read -p "Input minium nodes e.g. 1 : " NODE_MIN
export NODE_MIN=$NODE_MIN
read -p "Input maximum nodes e.g. 5 : " NODE_MAX
export NODE_MAX=$NODE_MAX
read -p "Input volume size in GB e.g. 15 : " VOLUMESIZE
export VOLUMESIZE=$VOLUMESIZE
read -p "Key name: " KEYNAME
export KEYNAME=$KEYNAME

# ------------------------------------
echo "deploy eks cluster"
# ------------------------------------
echo "eksctl create cluster --name $CLUSTERNAME --region $REGION --version "1.13" --tags "DESH=Cluster,Owner=someuser@somecompany.com" --nodegroup-name $NODEGROUPNAME --node-type $NODETYPE --nodes $NODES --nodes-min $NODE_MIN --nodes-max $NODE_MAX --node-volume-size $VOLUMESIZE --node-volume-type "gp2" --node-ami "auto" --node-labels "application=desh,nodeclass=workers" --ssh-public-key $KEYNAME"
eksctl create cluster --name $CLUSTERNAME --region $REGION --version "1.13" --tags "DESH=Cluster,Owner=someuser@somecompany.com" --nodegroup-name $NODEGROUPNAME --node-type $NODETYPE --nodes $NODES --nodes-min $NODE_MIN --nodes-max $NODE_MAX --node-volume-size $VOLUMESIZE --node-volume-type "gp2" --node-ami "auto" --node-labels "application=desh,nodeclass=workers" --ssh-public-key $KEYNAME
