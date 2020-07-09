#-----------------
# REFERENCES
#-----------------
# Script Name ::: prerequisties_windows.ps1
# Author      ::: RAND Corporation
#-----------------
# Chocolatey  ::: https://chocolatey.org/install
# Kubernetes  ::: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows
# AWS eksctl  ::: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
#-----------------

Import-module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

# parameters   
[string]$AWSACCESSKEY = $( Read-Host "Input AWS access key" )
[string]$AWSECRETACCESSKEY = $( Read-Host "Input AWS secret access key" )
[string]$REGION = $( Read-Host "Input AWS region" )

# user profile
$CURRENTUSER = Get-ChildItem env:userprofile | Select-Object -Property Value | Foreach-Object {If($_.Value){$_.Value}}

# install awscli
Invoke-WebRequest -Uri "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi" -OutFile "$CURRENTUSER\AWSCLI64PY3.msi"
Start-Process "msiexec.exe" -Wait -ArgumentList "/I $CURRENTUSER\AWSCLI64PY3.msi /quiet"

# configure awscli
aws configure set aws_access_key_id $AWSACCESSKEY
aws configure set aws_secret_access_key $AWSECRETACCESSKEY
aws configure set default.region $REGION

# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install kubectl
choco install kubernetes-cli -Force -y

# install aws-iam-authenticator
choco install aws-iam-authenticator -Force -y

# install eksctl
choco install eksctl -Force -y

# install OpenSSH
Install-Module -Force OpenSSHUtils
