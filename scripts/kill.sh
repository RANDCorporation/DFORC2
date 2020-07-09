kubectl delete -f /dforc2/desh/worker/kube/
kubectl delete -f /dforc2/desh/spark/kube/
kubectl delete -f /dforc2/desh/activemq/kube/
kubectl delete -f /dforc2/desh/postgres/kube/
kubectl delete -f /dforc2/desh/kafka_2/kube/
kubectl delete -f /dforc2/desh/solr/kube/
kubectl delete -f /dforc2/desh/zookeeper/kube/
kubectl get pods | grep Terminating | sed -r 's/^(spark-(master|worker)-controller-\S+)\s.*$/\1/p' | xargs -I % kubectl delete pod --grace-period=0 --force %
