#Autopsy

## Installing Autopsy on Ubuntu

The following instructions are for the installation of Autopsy for the "front end" of the DFORC2 distributed forensics toolkit. 

From clean Ubuntu 16.04 install:

Install Git:
```
$ sudo apt-get install git
```

Install dependencies:
```
$ sudo apt-get install wget git git-svn build-essential libssl-dev libbz2-dev libz-dev ant automake autoconf libtool vim python-dev uuid-dev libfuse-dev libcppunit-dev libafflib-dev libpq-dev dc3dd
$ sudo apt-get install openjdk-8-jdk openjfx
```

Install gstreamer:
```
$ list=$(apt-cache --names-only search ^gstreamer1.0-* | awk '{ print $1 }' | grep -v gstreamer1.0-hybris)
$ sudo apt-get install $list
```

Install libuna:
```
$ wget https://github.com/libyal/libuna/releases/download/20170112/libuna-alpha-20190102.tar.gz
$ tar xfv libuna-alpha-20190102.tar.gz 
$ cd libuna-20190102/
$ ./configure
$ make
$ sudo make install
```
Install libewf:
```
$ wget https://raw.github.com/libyal/legacy/master/libewf/libewf-20140608.tar.gz
$ tar xvfz libewf-20140608.tar.gz
$ cd libewf-20140608
$ ./configure --enable-python --enable-verbose-output --enable-debug-output --prefix=$HOME/tsk
$ make
$ make install
```

Install TSK:
```
$ git clone http://gitlab.com/randcorporation/sleuthkit.git
$ cd sleuthkit
$ ./bootstrap
$ ./configure --prefix=$HOME/tsk --with-libewf=$HOME/tsk --enable-java
$ make
$ make install
$ mkdir -p ~/tsk/bindings/java/dist
$ cp -v ~/tsk/share/java/Tsk_DataModel.jar ~/tsk/share/java/Tsk_DataModel_PostgreSQL.jar
$ cp -v ~/tsk/share/java/*.jar ~/tsk/bindings/java/dist
$ mkdir -p ~/tsk/bindings/java/lib
$ cp -v bindings/java/lib/*.jar ~/tsk/bindings/java/lib/
```

install Spark:
```
Download from https://www.apache.org/dyn/closer.lua/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz
$ tar -xvzf spark-2.2.0-bin-hadoop2.7
$ export SPARK_HOME=/path/to/spark-2.2.0-bin-hadoop2.7
```

Build Autopsy:
```
$ export JDK_HOME=/usr
$ export LIBEWF_HOME=$HOME/tsk
$ export TSK_HOME=$HOME/tsk
$ git clone git@gitlab.com:randcorporation/autopsy.git
$ cd autopsy
$ ant build
```

## Installing the Image2Cluster Module

Obtain or build the image2cluster NBM. In Autopsy, select “Plugins” from the “Tools” dropdown menu. Select the “Downloaded” tab and click “Add Plugins”. Navigate to the image2cluster NBM and install it. Allow Autopsy to restart.

Install PostgreSQL:
```
$ sudo apt-get install postgresql sshpass
$ sudo -u postgres psql postgres
```
At the postgres prompt, type “\password postgres”, hit enter, and enter the password as “postgres”. Then \q to quit.


Install nfs client:
```
$ sudo apt-get install nfs-common
```

As superuser, open /etc/postgresql/[version]/main/pg_hba.conf
Add a line at the top:
```
local	postgres	postgres	md5
```

As superuser, open /etc/hosts
Add two lines:
```
127.0.0.1	desh_postgres_local
[your remote DESH server’s IP]	desh_postgres
```

Configure Autopsy/Image2Cluster:
In Autopsy, select “Options” from the “Tools” dropdown. Select the “Multi-User” tab and check the box labeled “Enable multi-user cases”. Fill in the appropriate values.

(For the digitalevidence.rand.org environment:
Database:
host: localhost
port: 5432
username: postgres
pasword: postgres

Solr:
host: digitalevidence.rand.org
port: 31983

ActiveMQ
port 32616

Copy the lines from the "hosts" file in this repo into '/etc/hosts'. In the Autopsy directory, run the start script with the IP address of the DFORC2 cluster’s master node as an argument.
```
$ ./run.sh 10.25.0.1
```

Before running Autopsy, this script will mount the NFS server at /mnt. Copy the ‘desh-streaming-job-assembly-1.0.jar’, and the Postgresql JAR located at ‘autopsy/Experimental/release/modules/ext/postgresql-9.4-1201-jdbc41.jar’ to ‘/mnt/assembly’

# DFORC2
A digital evidence repo that deploys kubernetes in AWS.

### Reference Info
 
 - [Ubuntu](https://www.ubuntu.com/download/desktop)
 - [git](https://help.ubuntu.com/lts/serverguide/git.html)
 - [AWS CLI](https://aws.amazon.com/cli/)
 - [Docker Engine](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
 - [Docker Compose](https://docs.docker.com/compose/install/)
 - [Kubernetes](https://github.com/kubernetes/kubernetes/releases)
 - [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
 - [Kops](https://github.com/kubernetes/kops)
 
## Prerequisites

 - A VPC must be existing in aws before the DFORC2 solution can be deployed.
 - The VPC cidr block must also be known. An IPv4 cidr block is typically assigned a size of /16  
 
The DFORC2 user will require the following IAM permissions:

```
 - AmazonEC2FullAccess
 - AmazonRoute53FullAccess
 - AmazonS3FullAccess
 - IAMFullAccess
 - AmazonVPCFullAccess

```

## Step 1: Getting started

Follow steps below to install prerequisite software.

```
# install git dependencies
$ sudo apt-get install git -y --force-yes

# download dforc2 dependencies
$ git clone https://gitlab.com/randcorporation/dforc2.git --branch master

# at the prompt type in assigned git username
$ somebody@company.com

# at the prompt type in assigned git password
$ mypassword

# enable script execute privilege
$ chmod +x dforc2/scripts/*

```

## STEP 2: Install required software

**LINUX** ::: How to install required software for deploying a kubernetes cluster from a local laptop/desktop.

```
$ bash prerequisites_linux.sh
```

Below list the required parameters to pass in the script usage example above:

 1. **access-key-id** is the assigned aws access key: example `XXXXXXXXXXXXXXXX`

 2. **secret-access-key** is the assigned aws secret key: example `XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

 3. **default-region** is the assigned aws region: example `us-east-1`

**WINDOWS** ::: How to install required software for deploying a kubernetes cluster from a local laptop/desktop. 

```
$ .\prerequisites_windows.ps1
```

Below list the required parameters to pass in the script when prompted:

 1. **access-key-id** is the assigned aws access key: example `XXXXXXXXXXXXXXXX`

 2. **secret-access-key** is the assigned aws secret key: example `XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

 3. **default-region** is the assigned aws region: example `us-east-1` 
 
## STEP 3: Deploying a kubernetes cluster for DFORC2 

**LINUX** ::: How to deploy a kubernetes cluster from your local desktop.

```
$ bash dforc2-deploy.sh
```

Below list the required parameters to pass in the script usage example above:

 1. **clustername** the unique cluster name assigned to the kubernetes cluster: example `myeks`

 2. **nodegroupname** the name assigned for the node group: example `node-workers`
 
 3. **default-region** is the assigned aws region: example `us-east-1`

 4. **nodetype** is the AWS EC2 instance type to be assigned for each node deployed in a kubernetes cluster: example `t3.medium`

 5. **nodes** is the designated number of nodes to be deployed in a kubernetes cluster: example `3`

 6. **node_min** is the min number of nodes allowed to be deployed in a kubernetes cluster: example `1` 
 
 7. **node_max** is the max number of nodes allowed to be deployed in a kubernetes cluster: example `5`
 
 8. **volumesize** is the volume size in GB for each worker node deployed: example `15`

**WINDOWS** ::: How to deploy a kubernetes cluster from your local desktop.
 
```
$ .\dforc2-deploy.ps1
```

Below list the required parameters to pass in the script usage example above:

 1. **clustername** the unique cluster name assigned to the kubernetes cluster: example `myeks`

 2. **nodegroupname** the name assigned for the node group: example `node-workers`
 
 3. **default-region** is the assigned aws region: example `us-east-1`

 4. **nodetype** is the AWS EC2 instance type to be assigned for each node deployed in a kubernetes cluster: example `t3.medium`

 5. **nodes** is the designated number of nodes to be deployed in a kubernetes cluster: example `3`

 6. **node_min** is the min number of nodes allowed to be deployed in a kubernetes cluster: example `1` 
 
 7. **node_max** is the max number of nodes allowed to be deployed in a kubernetes cluster: example `5`
 
 8. **volumesize** is the volume size in GB for each worker node deployed: example `15`

## STEP 4: DFORC2 MENU: Deleting a kubernetes cluster 

**LINUX** ::: How to delete a kubernetes cluster from your local desktop.

```
$ bash dforc2-delete.sh
```

Below list the required parameters to pass in the script usage example above:

 1. **clustername** the unique cluster name assigned to the kubernetes cluster: example `myeks`

**WINDOWS** ::: How to delete a kubernetes cluster from your local desktop.

```
$ .\dforc2-delete.ps1
```

 1. **clustername** the unique cluster name assigned to the kubernetes cluster: example `myeks`

## Deploying DESH

Clone this repository again, and move it to the filesystem root.

```
$ git clone https://username@gitlab.com/randcorporation/dforc2.git
$ sudo mv dforc2 /
```

Edit the worker definition at /dforc2/desh/worker/kube/desh-worker-controller.yaml by setting the environment variable CASE_NAME to the intended name of your first Autopsy case. Please restrict it to lowercase letters, numbers, and underscores

Start the cluster by executing the start script.

```
$ bash /dforc2/scripts/start_desh.sh
```

When prompted for the disk size, enter the sum of the sizes of the disks you plan to run with this cluster.

## Accessing the Kubernetes Dashboard

Before accessing the Kubernetes Dashboard, an eks-admin service account must be created, and the kubectl proxy started. The latter command will continue to run in the terminal, which must remain open.

```
$ kubectl apply -f /dforc2/src/eks-admin-service-account.yaml
$ kubectl proxy
```

To access the dashboard, a token must be taken from the eks-admin account. The following command will describe the account, including the token.

```
$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```

Below is an example output:
```
Name:         eks-admin-token-b5zv4
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=eks-admin
              kubernetes.io/service-account.uid=bcfe66ac-39be-11e8-97e8-026dce96b6e8

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      <authentication_token>
```

Copy the block following `token`, and, using a browser on the same computer, navigate to `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login`. From the authentication options, select "Token", paste the copied block into the prompt, and sign in.

## Changing cases

In order to process a new case, the worker pods must be reset.

```
$ kubectl delete -f /dforc2/desh/worker/kube/desh-worker-controller.yaml
```

Edit the file again to set the name of the new case, then restart the workers.

```
$ kubectl create -f /dforc2/desh/worker/kube/desh-worker-controller.yaml
```

# FileWorkerApp

Processes individual logical files found by the spark streaming job.

## Example Usage (digitalevidence):
```
java ${JAVA_RUN_FLAGS} \
    -classpath /mnt/assembly/activemq-all-5.11.1.jar:/mnt/assembly/postgresql-9.4-1203.jdbc4.jar:/mnt/assembly/org-openide-dialogs.jar:/mnt/assembly/desh-streaming-job-assembly-1.0.jar:/mnt/assembly/org-openide-awt.jar:/mnt/assembly/org-openide-filesystems.jar:/mnt/assembly/org-openide-modules.jar:/mnt/assembly/org-openide-util-lookup.jar:/mnt/assembly/org-openide-util.jar:/mnt/assembly/org-openide-windows.jar:/mnt/assembly/org-netbeans-api-progress.jar:/mnt/assembly/org-sleuthkit-autopsy-core.jar:/mnt/assembly/org-sleuthkit-autopsy-keywordsearch.jar:/mnt/assembly/org-netbeans-api-progress.jar:/mnt/assembly/org-sleuthkit-autopsy-corelibs.jar:/mnt/assembly/org-netbeans-modules-progress-ui.jar:/mnt/assembly/log4j2.properties \
    org.desh.worker.FileWorkerApp \
    -build-dir ${FILE_SYSTEM_PATH}/build \
    -case-dir ${FILE_SYSTEM_PATH}/casefiles \
    -case-name ${CASE_NAME} \
    -postgres-host ${PG_SERVER} \
    -postgres-port ${PG_PORT} \
    -postgres-user postgres \
    -postgres-pass postgres \
    -solr-port ${SOLR_PORT} \
    -solr-host ${SOLR_SERVER} \
    -activemq-host ${ACTIVEMQ_SERVER} \
    -activemq-port ${ACTIVEMQ_PORT} \
    -activemq-user activemq \
    -activemq-pass activemq \
    -sleep ${SLEEP_TIME:-0}
```

## Example Docker container configuration (digitalevidence)
```
docker run \
    --rm  \
    --add-host postgres-service:10.3.7.22 \
    --add-host solr-service:10.3.7.22 \
    --add-host activemq:10.3.7.22 \
    --name desh_worker \
    -e FILE_SYSTEM_PATH=/mnt/storage/ \
    -e CASE_NAME=ttran_40_51 \
    -e PG_SERVER=postgres-service \
    -e PG_PORT=32432 \
    -e SOLR_SERVER=solr-service \
    -e SOLR_PORT=8983 \
    -e ACTIVEMQ_SERVER=activemq \
    -e ACTIVEMQ_PORT=32616 \
    -e SLEEP_TIME:-0=0 \
    -e LD_LIBRARY_PATH=/opt/sleuthkit/tsk/.libs  \
    -e JAVA_RUN_FLAGS="-Djava.awt.headless=false" \
    -v /opt/digitalevidence/run_desh_local/cases:/mnt/storage/casefiles/  \
    -v /opt/digitalevidence/home/ttran/RAND/autopsy/build:/mnt/storage/build \
    -v /opt/digitalevidence/home/ttran/RAND/autopsy/build:/opt/autopsy-collaborative-build/build    \
    -v /opt/digitalevidence/run_autopsy_docker/assembly:/mnt/assembly  \
    -v /opt/digitalevidence/run_desh_local/storage/:/mnt/storage \
    gordianknot.rand.org:5001/desh_worker
```
