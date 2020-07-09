#!/bin/bash

#------------------------------------------------------------------------------
# "start_desh.sh" script variables
#------------------------------------------------------------------------------

kube_status="kubernetes Dashboard"
nfs_pod_status="kubernetes Pod: NFS MOUNT"
activemq_pod_status="kubernetes Pod: ACTIVEMQ"
postgres_pod_status="kubernetes Pod: POSTGRES"
kafka_pod_status="kubernetes Pod: KAFKA"
zookeeper_pod_status="kubernetes Statefulset: ZOOKEEPER"
solr_pod_status="kubernetes Pod: SOLR"
spark_pod_status="kubernetes Pod: SPARK"
kube_value=""
kube_value2="<none>"
disk_size_kafka=""
disk_size=""
kube_nfs_service="NONE"

echo "Enter evidence disk size in Gigabits:"
read disk_size

disk_size_kafka=$(( ${disk_size} / 9 )) 

disk_size="${disk_size}Gi"
disk_size_kafka="${disk_size_kafka}Gi"

echo "Disk size: ${disk_size}"
echo "Disk size kafka: $disk_size_kafka"

#------------------------------------------------------------------------------
# Launch Kubernetes Dashboard
#------------------------------------------------------------------------------

#kubectl create -f /dforc2/desh/dashboard/kube/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
#------------------------------------------------------------------------------
# Waiting for Kubernetes Dashboard IP address to be assigned
# Once Kubernetes Dashboard IP address assigned - Deploy NFS
#------------------------------------------------------------------------------

function kube-dashboard {
  while true; do
      echo "waiting for ${kube_status}"
      kube_dash=$(kubectl describe services --namespace="kube-system" -l k8s-app=kubernetes-dashboard | grep "Endpoints:\s*[0-9]" |  sed -e "s/Endpoints:\s*//")    
    if [[ -z "$kube_dash" ]]; then
      echo "Waiting for ${kube_status} to not be ${kube_value} (currently ${kube_dash})"
      sleep 60
      kube-dashboard
    else
      echo "IP address assigned for ${kube_status} (currently ${kube_dash})"
      echo "Setting up disk size for NFS"
      sudo find /dforc2/desh/ -name "*.yaml.template" -exec sudo bash /dforc2/scripts/apply_template.sh {} ${kube_nfs_service} ${disk_size_kafka} ${disk_size} \;
      echo "Deploying Kubernetes NFS pod"
      kubectl create -f /dforc2/desh/nfs/kube/
      echo "Kubernetes NFS pod deployed"
      break 
    fi
  done
}

kube-dashboard

#------------------------------------------------------------------------------
# Waiting for NFS MOUNT IP address to be assigned
# Update NFS dependent "*.yaml" files
#------------------------------------------------------------------------------

function nfs-mount {
  while true; do
      echo "waiting for ${nfs_pod_status}"
      kube_nfs=$(kubectl describe pods -l role=nfs-server | grep "IP:\s*[0-9]" | sed -e "s/IP:\s*//")    
      kube_nfs_service=$(kubectl describe service nfs-server | grep "IP:\s*[0-9]" | sed -e "s/IP:\s*//")
    if [[ -z "$kube_nfs" ]]; then
      echo "Waiting for ${nfs_pod_status} to not be ${kube_value} (currently ${kube_nfs})"
      sleep 60
      nfs-mount
    else
      echo "IP address assigned for ${nfs_pod_status} (currently ${kube_nfs})"
      break
    fi
  done
}

nfs-mount

echo "Setting up disk size and NFS IP"
sudo find /dforc2/desh/ -name "*.yaml.template" -exec sudo bash /dforc2/scripts/apply_template.sh {} ${kube_nfs_service} ${disk_size_kafka} ${disk_size} \;
echo "Creating NFS-PVs"
kubectl create -f /dforc2/desh/nfs/kube/pvs

function zookeeper {
  while true; do
      echo "waiting for ${zookeeper_pod_status}"
      kube_zookeeper=$(kubectl describe statefulset -l app=zk | grep "0 Waiting")    
    if [[ -z "$kube_zookeeper" ]]; then
      echo "Waiting for ${zookeeper_pod_status} to not be ${kube_value} (currently ${kube_zookeeper})"
      sleep 60
      zookeeper
    else
      echo "Not waiting on any zookeeper pods"
      break 
    fi
  done
}

#--------------------------------

function kafka {
  while true; do
      echo "waiting for ${kafka_pod_status}"
      kube_kafka=$(kubectl describe pods -l name=kafka | grep "Node:\s*[i]" | sed -e "s:.*\/::")    
    if [[ -z "$kube_kafka" ]]; then
      echo "Waiting for ${kafka_pod_status} to not be ${kube_value} (currently ${kube_kafka})"
      sleep 60
      kafka
    else
      echo "IP address assigned for ${kafka_pod_status} (currently ${kube_kafka})"
      echo "Updating IP address for KAFKA environment file"
      find /dforc2/desh/ -name "env.sh" -exec sed -i "s/KAFKA_POD_IP_ADDRESS/${kube_kafka}/" {} \;
      echo "IP address updated for KAFKA environment file"
      break 
    fi
  done
}



#------------------------------------------------------------------------------
# Create/Deploy Kubernetes pods (activemq, postgres, kafka, solr, spark-master) 
#------------------------------------------------------------------------------

kubectl create -f /dforc2/desh/activemq/kube/
kubectl create -f /dforc2/desh/postgres/kube/
kubectl create -f /dforc2/desh/solr/kube/
kubectl create -f /dforc2/desh/spark/kube/
kubectl create -f /dforc2/desh/zookeeper/kube/
zookeeper
kubectl create -f /dforc2/desh/kafka_2/kube/
kafka
kubectl create -f /dforc2/desh/worker/kube/

sleep 15

#------------------------------------------------------------------------------
# Waiting for IP addresses to be assigned to Kubernetes pods
# Update "env.sh" environment output file
#------------------------------------------------------------------------------


function activemq {
  while true; do
      echo "waiting for ${activemq_pod_status}"
      kube_activemq=$(kubectl describe pods -l name=activemq | grep "Node:\s*[i]" | sed -e "s:.*\/::")    
    if [[ -z "$kube_activemq" ]]; then
      echo "Waiting for ${activemq_pod_status} to not be ${kube_value} (currently ${kube_activemq})"
      sleep 60
      activemq
    else
      echo "IP address assigned for ${activemq_pod_status} (currently ${kube_activemq})"
      echo "Updating IP address for ACTIVEMQ environment file"
      find /dforc2/desh/ -name "*env.sh" -exec sed -i "s/ACTIVEMQ_POD_IP_ADDRESS/${kube_activemq}/" {} \;
      echo "IP address updated for ACTIVEMQ environment file"
      break 
    fi
  done
}

activemq

#--------------------------------

function postgres {
  while true; do
      echo "waiting for ${postgres_pod_status}"
      kube_postgres=$(kubectl describe pods -l name=postgres | grep "Node:\s*[i]" | sed -e "s:.*\/::")    
    if [[ -z "$kube_postgres" ]]; then
      echo "Waiting for ${postgres_pod_status} to not be ${kube_value} (currently ${kube_postgres})"
      sleep 60
      postgres
    else
      echo "IP address assigned for ${postgres_pod_status} (currently ${kube_postgres})"
      echo "Updating IP address for POSTGRES environment file"
      find /dforc2/desh/ -name "env.sh" -exec sed -i "s/POSTGRES_POD_IP_ADDRESS/${kube_postgres}/" {} \;
      echo "IP address updated for POSTGRES environment file"
      break 
    fi
  done
}

postgres

#--------------------------------

function solr {
  while true; do
      echo "waiting for ${solr_pod_status}"
      kube_solr=$(kubectl describe pods -l name=solr | grep "Node:\s*[i]" | sed -e "s:.*\/::")    
    if [[ -z "$kube_solr" ]]; then
      echo "Waiting for ${solr_pod_status} to not be ${kube_value} (currently ${kube_solr})"
      sleep 60
      solr
    else
      echo "IP address assigned for ${solr_pod_status} (currently ${kube_solr})"
      echo "Updating IP address for SOLR environment file"
      find /dforc2/desh/ -name "*env.sh" -exec sed -i "s/SOLR_POD_IP_ADDRESS/${kube_solr}/" {} \;
      echo "IP address updated for SOLR environment file"
      break 
    fi
  done
}

solr

#--------------------------------

function spark {
  while true; do
      echo "waiting for ${spark_pod_status}"
      kube_spark=$(kubectl describe pods -l component=spark-master | grep "Node:\s*[i]" | sed -e "s:.*\/::")    
    if [[ -z "$kube_spark" ]]; then
      echo "Waiting for ${spark_pod_status} to not be ${kube_value} (currently ${kube_spark})"
      sleep 60
      spark
    else
      echo "IP address assigned for ${spark_pod_status} (currently ${kube_spark})"
      echo "Updating IP address for SPARK environment file"
      find /dforc2/desh/ -name "*env.sh" -exec sed -i "s/SPARK_POD_IP_ADDRESS/${kube_spark}/" {} \;
      echo "IP address updated for SPARK environment file"
      break 
    fi
  done
}

spark

#--------------------------------
# End "start_desh.sh" script
#--------------------------------

echo "Script run completed"
