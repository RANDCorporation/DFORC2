#-----------------
# REFERENCES
#-----------------
# Script Name ::: dforc2-deploy.ps1
# Author      ::: RAND Corporation
#-----------------
# AWS eksctl  ::: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
#-----------------

Import-module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

#------------------------------------------
Write-Host "input parameters" -ForegroundColor Yellow
#------------------------------------------  
[string]$CLUSTERNAME = $( Read-Host "Input cluster name" )
[string]$NODEGROUPNAME = $( Read-Host "Input node worker group name e.g. desh-workers" )
[string]$REGION = $( Read-Host "Input AWS region" )
[string]$NODETYPE = $( Read-Host "Input EC2 instance type e.g. t3.medium" )
[int]$NODES = $( Read-Host "Input total nodes to deploy e.g. 3" )
[int]$NODE_MIN = $( Read-Host "Input minium nodes e.g. 1" )
[int]$NODE_MAX = $( Read-Host "Input maximum nodes e.g. 5" )
[int]$VOLUMESIZE = $( Read-Host "Input volume size in GB e.g. 15" )

#------------------------------------------
Write-Host "deploy eks cluster" -ForegroundColor Yellow
#------------------------------------------
eksctl create cluster --name $CLUSTERNAME --region $REGION --version "1.13" --tags "DESH=Cluster,Owner=someuser@somecompany.com" --nodegroup-name $NODEGROUPNAME --node-type $NODETYPE --nodes $NODES --nodes-min $NODE_MIN --nodes-max $NODE_MAX --node-volume-size $VOLUMESIZE --node-volume-type "gp2" --node-ami "auto" --node-labels "application=desh,nodeclass=workers"
