#!/bin/bash
# -----------------------------------------------------------------------------
# "SCRIPT USAGE DESCRIPTION"
# -----------------------------------------------------------------------------
if [ $# -eq 0 ]
 then
   echo "Config Usage 1: dforc2-startup <access-key-id> <secret-access-key> <default-region>"
   echo "Deploy Usage 2: dforc2-startup <default-region> <s3-bucket-name> <vpc-IPv4-cidr-block> <kops-cluster-name>"
   echo "Delete Usage 3: dforc2-startup <default-region> <s3-bucket-name> <kops-cluster-name>"
   exit 0
fi
# -----------------------------------------------------------------------------
# "SET FUNCTION VARS"
# -----------------------------------------------------------------------------
function press_enter
{
    echo ""
    echo -n "Press Enter to continue"
    read
    clear
}
# -----------------------------------------------------------------------------
# "INSTALL REQUIRED SOFTWARE"
# -----------------------------------------------------------------------------
function install_Bits
{
 # ------------------------------------
 echo "install aws cli & set access keys"
 # ------------------------------------
 sudo apt-get install python -y
 sudo apt-get install unzip -y
 curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
 unzip awscli-bundle.zip
 sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
 echo "setting aws cli access keys"
 aws configure set aws_access_key_id $1
 aws configure set aws_secret_access_key $2
 aws configure set default.region $3
 # ------------------------------------
 echo "install docker engine"
 # ------------------------------------
 sudo apt-get update
 sudo apt-get install -y \
   apt-transport-https \
   ca-certificates \
   curl \
   software-properties-common
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
 sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
 sudo apt-get update
 sudo apt-get install docker-ce -y
 # ------------------------------------
 echo "install docker compose"
 # ------------------------------------
 sudo curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
 sudo chmod +x /usr/local/bin/docker-compose
 sudo usermod -aG docker ubuntu
 # ------------------------------------
 echo "installing kubernetes & kubectl command-line"
 # ------------------------------------ 
 cd ~/dforc2
 git clone https://github.com/kubernetes/kubernetes.git --branch release-1.9
 curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.9.2/bin/linux/amd64/kubectl
 sudo chmod +x ./kubectl
 sudo mv ./kubectl /usr/local/bin/kubectl
 # ------------------------------------
 echo "installing kops command-line"
 # ------------------------------------ 
 git clone https://github.com/kubernetes/kops.git --branch release-1.8
 wget https://github.com/kubernetes/kops/releases/download/1.8.0/kops-linux-amd64
 sudo chmod +x kops-linux-amd64
 sudo mv kops-linux-amd64 /usr/local/bin/kops
 cd ~
}
# -----------------------------------------------------------------------------
# "LAUNCHING A KOPS CLUSTER"
# -----------------------------------------------------------------------------
function user1_kubeUp
{
 # ------------------------------------
 echo "creating kops ssh key"
 # ------------------------------------
 sudo mkdir -p ~/.ssh
 sudo ssh-keygen -f ~/.ssh/kops-key  -t rsa -b 4096 -q -P ""
 # ------------------------------------
 echo "creating default s3 bucket"
 # ------------------------------------
 aws s3api create-bucket --bucket $2 --region $1
 # ------------------------------------
 echo "creating aws-varinputs.conf file"
 # ------------------------------------ 
 sudo cat ~/dforc2/src/aws.conf > ~/dforc2/src/aws-var-inputs.conf
 # ------------------------------------
 echo "sourcing kops file"
 # ------------------------------------
 source ~/dforc2/src/aws-var-inputs.conf
 # ------------------------------------
 echo "creating kops cluster"
 # ------------------------------------
 kops update cluster $4.k8s.local --yes --state s3://$2/
 # ------------------------------------
 echo "launching DESH pods"
 # ------------------------------------
 # sleep 180    
 # /dforc2/scripts/start_desh.sh 
}

function user2_kubeUp
{
 # ------------------------------------
 echo "creating kops ssh key"
 # ------------------------------------
 sudo mkdir -p ~/.ssh
 sudo ssh-keygen -f ~/.ssh/kops-key  -t rsa -b 4096 -q -P ""
 # ------------------------------------
 echo "creating default s3 bucket"
 # ------------------------------------
 aws s3api create-bucket --bucket $2 --region $1
 # ------------------------------------
 echo "creating aws-varinputs.conf file"
 # ------------------------------------ 
 sudo cat ~/dforc2/src/aws.conf > ~/dforc2/src/aws-var-inputs.conf
 # ------------------------------------
 echo "configuring kops source file"
 # ------------------------------------
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_REGION/$1/" {} \; | sleep 2
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_S3_BUCKET/$2/" {} \; | sleep 2
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_CLUSTER_NAME/$4/" {} \; | sleep 2
 VPCID=`aws ec2 describe-vpcs --filters Name=cidr-block-association.cidr-block,Values=$3 --region $1 --query 'Vpcs[*].VpcId' --output text` 
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_VPC_ID/${VPCID}/" {} \; | sleep 2
 VPC_CIDR=`echo "$3" | sed -e "s/...$//"`
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_VPC_CIDR/${VPC_CIDR}/" {} \; | sleep 2  
 # ------------------------------------
 echo "sourcing kops file"
 # ------------------------------------
 source ~/dforc2/src/aws-var-inputs.conf
 # ------------------------------------
 echo "downloading kops cluster config files"
 # ------------------------------------ 
 aws s3 cp s3://$2/$4.k8s.local/cluster.spec ~/dforc2/src/cluster.spec
 aws s3 cp s3://$2/$4.k8s.local/config ~/dforc2/src/config
 sleep 2
 # ------------------------------------
 echo "modifying cluster.spec & config defaults"
 # ------------------------------------ 
 DEFAULTSUBNET=`echo "${VPC_CIDR}" | sed -e "s/...$/32.0/"`
 SUBNET1=`echo "${VPC_CIDR}" | sed -e "s/...$/96.0/"`
 find ~/dforc2/src/cluster.spec -exec sed -i "s/- cidr: ${DEFAULTSUBNET}/- cidr: ${SUBNET1}/" {} \; | sleep 3 
 find ~/dforc2/src/config -exec sed -i "s/- cidr: ${DEFAULTSUBNET}/- cidr: ${SUBNET1}/" {} \; | sleep 3
 SUBNET2=`echo "${VPC_CIDR}" | sed -e "s/...$/64.0/"`
 find ~/dforc2/src/cluster.spec -exec sed -i "s/- cidr: ${VPC_CIDR}/- cidr: ${SUBNET2}/" {} \; | sleep 3 
 find ~/dforc2/src/config -exec sed -i "s/- cidr: ${VPC_CIDR}/- cidr: ${SUBNET2}/" {} \; | sleep 3
 # ------------------------------------
 echo "uploading cluster.spec & config files to s3"
 # ------------------------------------ 
 aws s3 cp ~/dforc2/src/cluster.spec s3://$2/$4.k8s.local/cluster.spec
 aws s3 cp ~/dforc2/src/config s3://$2/$4.k8s.local/config
 sleep 2
 # ------------------------------------
 echo "creating kops cluster"
 # ------------------------------------
 kops update cluster $4.k8s.local --yes --state s3://$2/
 # ------------------------------------
 echo "launching DESH pods"
 # ------------------------------------
 # sleep 180    
 # /dforc2/scripts/start_desh.sh 
}

function user3_kubeUp
{
 # ------------------------------------
 echo "creating kops ssh key"
 # ------------------------------------
 sudo mkdir -p ~/.ssh
 sudo ssh-keygen -f ~/.ssh/kops-key  -t rsa -b 4096 -q -P ""
 # ------------------------------------
 echo "creating default s3 bucket"
 # ------------------------------------
 aws s3api create-bucket --bucket $2 --region $1
 # ------------------------------------
 echo "creating aws-varinputs.conf file"
 # ------------------------------------ 
 sudo cat ~/dforc2/src/aws.conf > ~/dforc2/src/aws-var-inputs.conf
 # ------------------------------------
 echo "configuring kops source file"
 # ------------------------------------
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_REGION/$1/" {} \; | sleep 2
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_S3_BUCKET/$2/" {} \; | sleep 2
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_CLUSTER_NAME/$4/" {} \; | sleep 2
 VPCID=`aws ec2 describe-vpcs --filters Name=cidr-block-association.cidr-block,Values=$3 --region $1 --query 'Vpcs[*].VpcId' --output text` 
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_VPC_ID/${VPCID}/" {} \; | sleep 2
 VPC_CIDR=`echo "$3" | sed -e "s/...$//"`
 find ~/dforc2/src/aws-var-inputs.conf -exec sed -i "s/MY_VPC_CIDR/${VPC_CIDR}/" {} \; | sleep 2 
 # ------------------------------------
 echo "sourcing kops file"
 # ------------------------------------
 source ~/dforc2/src/aws-var-inputs.conf
 # ------------------------------------
 echo "downloading kops cluster config files"
 # ------------------------------------ 
 aws s3 cp s3://$2/$4.k8s.local/cluster.spec ~/dforc2/src/cluster.spec
 aws s3 cp s3://$2/$4.k8s.local/config ~/dforc2/src/config
 sleep 2
 # ------------------------------------  
 echo "modifying cluster.spec & config defaults"
 # ------------------------------------  
 DEFAULTSUBNET=`echo "${VPC_CIDR}" | sed -e "s/...$/32.0/"`
 SUBNET1=`echo "${VPC_CIDR}" | sed -e "s/...$/160.0/"`
 find ~/dforc2/src/cluster.spec -exec sed -i "s/- cidr: ${DEFAULTSUBNET}/- cidr: ${SUBNET1}/" {} \; | sleep 3 
 find ~/dforc2/src/config -exec sed -i "s/- cidr: ${DEFAULTSUBNET}/- cidr: ${SUBNET1}/" {} \; | sleep 3
 SUBNET2=`echo "${VPC_CIDR}" | sed -e "s/...$/128.0/"`
 find ~/dforc2/src/cluster.spec -exec sed -i "s/- cidr: ${VPC_CIDR}/- cidr: ${SUBNET2}/" {} \; | sleep 3 
 find ~/dforc2/src/config -exec sed -i "s/- cidr: ${VPC_CIDR}/- cidr: ${SUBNET2}/" {} \; | sleep 3
 # ------------------------------------
 echo "uploading cluster.spec & config files to s3"
 # ------------------------------------ 
 aws s3 cp ~/dforc2/src/cluster.spec s3://$2/$4.k8s.local/cluster.spec
 aws s3 cp ~/dforc2/src/config s3://$2/$4.k8s.local/config
 sleep 2
 # ------------------------------------
 echo "creating kops cluster"
 # ------------------------------------
 kops update cluster $4.k8s.local --yes --state s3://$2/
 # ------------------------------------
 echo "launching DESH pods"
 # ------------------------------------
 # sleep 180    
 # /dforc2/scripts/start_desh.sh 
}
# -----------------------------------------------------------------------------
# "DELETING A KOPS CLUSTER"
# -----------------------------------------------------------------------------
function user1_kubeDown
{
 # ------------------------------------  
 echo "removing kops cluster"
 # ------------------------------------  
 kops delete cluster --name=$3.k8s.local --yes --state s3://$2
 # ------------------------------------ 
 echo "deleting s3 bucket"
 # ------------------------------------  
 aws s3api delete-bucket --bucket $2 --region $1
 sudo rm ~/.ssh/kop*
 sudo rm ~/dforc2/src/aws-var-inputs.conf
 sudo rm ~/dforc2/src/cluster.spec
 sudo rm ~/dforc2/src/config 
}

function user2_kubeDown
{
 # ------------------------------------  
 echo "removing kops cluster"
 # ------------------------------------  
 kops delete cluster --name=$3.k8s.local --yes --state s3://$2
 # ------------------------------------ 
 echo "deleting s3 bucket"
 # ------------------------------------  
 aws s3api delete-bucket --bucket $2 --region $1
 sudo rm ~/.ssh/kop*
 sudo rm ~/dforc2/src/aws-var-inputs.conf
 sudo rm ~/dforc2/src/cluster.spec
 sudo rm ~/dforc2/src/config 
}

function user3_kubeDown
{
 # ------------------------------------  
 echo "removing kops cluster"
 # ------------------------------------  
 kops delete cluster --name=$3.k8s.local --yes --state s3://$2
 # ------------------------------------ 
 echo "deleting s3 bucket"
 # ------------------------------------  
 aws s3api delete-bucket --bucket $2 --region $1
 sudo rm ~/.ssh/kop*
 sudo rm ~/dforc2/src/aws-var-inputs.conf 
 sudo rm ~/dforc2/src/cluster.spec
 sudo rm ~/dforc2/src/config
}
# -----------------------------------------------------------------------------
# "DFORC2 MENU LOOP"
# -----------------------------------------------------------------------------
while :
do
echo ""
echo "----------------------------------"
echo " DFORC2 MAIN MENU"
echo "----------------------------------"
echo -e "\t(1) install required software"
echo -e "\t(2) user 1"
echo -e "\t(3) user 2"
echo -e "\t(4) user 3"
echo -e "\t(5) Exit Menu "
echo ""
echo -n " Enter Selection: "
read choice
echo ""
case $choice in
    "1"|"1")
    while :
    do
    echo "----------------------------------"
    echo " DFORC2 INSTALL MENU"
    echo "----------------------------------"
    echo -e "\t(1) install required software"
    echo -e "\t(2) Exit Menu"
    echo ""
    echo -n " Enter Selection: "
    read choice1
    case $choice1 in
        "1"|"1")
            install_Bits $1 $2 $3
	break
        ;;
        "2"|"2")
            echo "Exiting Menu"
        break
        ;;
            *)
            echo "Exiting Menu"
            ;;
    esac
    done
	exit
    ;;
    "2"|"2")
    while :
    do
    echo "----------------------------------"
    echo " DFORC2 CLUSTER MENU"
    echo "----------------------------------"
    echo -e "\t(1) create a kops cluster"
    echo -e "\t(2) delete a kops cluster"
    echo -e "\t(3) Exit Menu"
    echo ""
    echo -n " Enter Selection: "
    read choice1
    case $choice1 in
        "1"|"1")
            user1_kubeUp $1 $2 $3 $4
	break
        ;;
        "2"|"2")
            user1_kubeDown $1 $2 $3
	break
        ;;
        "3"|"3")
            echo "Exiting Menu"
        break
        ;;
            *)
            echo "Exiting Menu"
            ;;
    esac
    done
	exit
    ;;
    "3"|"3")
    while :
    do
    echo "----------------------------------"
    echo " DFORC2 CLUSTER MENU"
    echo "----------------------------------"
    echo -e "\t(1) create a kops cluster"
    echo -e "\t(2) delete a kops cluster"
    echo -e "\t(3) Exit Menu"
    echo ""
    echo -n " Enter Selection: "
    read choice1
    case $choice1 in
        "1"|"1")
            user2_kubeUp $1 $2 $3 $4
	break
        ;;
        "2"|"2")
            user2_kubeDown $1 $2 $3
	break
        ;;
        "3"|"3")
            echo "Exiting Menu"
        break
        ;;
            *)
            echo "Exiting Menu"
            ;;
    esac
    done
	exit
    ;;
    "4"|"4")
    while :
    do
    echo "----------------------------------"
    echo " DFORC2 CLUSTER MENU"
    echo "----------------------------------"
    echo -e "\t(1) create a kops cluster"
    echo -e "\t(2) delete a kops cluster"
    echo -e "\t(3) Exit Menu"
    echo ""
    echo -n " Enter Selection: "
    read choice1
    case $choice1 in
        "1"|"1")
            user3_kubeUp $1 $2 $3 $4
	break
        ;;
        "2"|"2")
            user3_kubeDown $1 $2 $3
	break
        ;;
        "3"|"3")
            echo "Exiting Menu"
        break
        ;;
            *)
            echo "Exiting Menu"
            ;;
    esac
    done
	exit
    ;;		
    "5"|"5")
            echo "Exiting Menu"
    exit
    ;;
        *)
        echo "invalid answer, please try again"
        ;;
esac
done





