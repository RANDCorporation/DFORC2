#-----------------
# REFERENCES
#-----------------
# Script Name ::: dforc2-delete.ps1
# Author      ::: RAND Corporation
#-----------------
# AWS eksctl  ::: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
#-----------------

Import-module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

#------------------------------------------
Write-Host "input parameters" -ForegroundColor Yellow
#------------------------------------------
[string]$CLUSTERNAME = $( Read-Host "Input cluster name" )

#------------------------------------------
Write-Host "delete eks cluster" -ForegroundColor Yellow
#------------------------------------------
eksctl delete cluster --name $CLUSTERNAME
