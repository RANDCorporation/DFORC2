echo `kubectl describe pods -l name=kafka | grep "Node:" | sed -e "s:.*\/::"`	kafka-0
echo `kubectl describe pods -l name=kafka-1 | grep "Node:" | sed -e "s:.*\/::"`	kafka-1
echo `kubectl describe pods -l name=kafka-2 | grep "Node:" | sed -e "s:.*\/::"`	kafka-2
echo `kubectl describe pods -l name=kafka-3 | grep "Node:" | sed -e "s:.*\/::"`	kafka-3
echo `kubectl describe pods -l name=kafka-4 | grep "Node:" | sed -e "s:.*\/::"`	kafka-4
echo `kubectl describe pods -l name=kafka-5 | grep "Node:" | sed -e "s:.*\/::"`	kafka-5
echo `kubectl describe pods -l name=kafka-6 | grep "Node:" | sed -e "s:.*\/::"`	kafka-6
echo `kubectl describe pods -l name=kafka-7 | grep "Node:" | sed -e "s:.*\/::"`	kafka-7
echo `kubectl describe pods -l name=kafka-8 | grep "Node:" | sed -e "s:.*\/::"`	kafka-8
echo `kubectl describe pods -l name=kafka-9 | grep "Node:" | sed -e "s:.*\/::"`	kafka-9

echo `kubectl describe pods zk-0 | grep "Node:" | sed -e "s:.*\/::"`	zk-0.zk-headless.default.svc.cluster.local  
echo `kubectl describe pods zk-1 | grep "Node:" | sed -e "s:.*\/::"`	zk-1.zk-headless.default.svc.cluster.local  

echo `kubectl describe pods -l name=postgres | grep "Node:" | sed -e "s:.*\/::"`	postgres-service	
echo `kubectl describe pods -l component=spark-master | grep "Node:" | sed -e "s:.*\/::"`	spark-service	
echo `kubectl describe pods -l name=activemq | grep "Node:" | sed -e "s:.*\/::"`	activemq-service	
echo `kubectl describe pods -l name=solr | grep "Node:" | sed -e "s:.*\/::"`	solr-service	
echo `kubectl describe pods -l role=nfs-server | grep "Node:" | sed -e "s:.*\/::"`    nfs-service
