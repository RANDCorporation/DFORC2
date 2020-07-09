/opt/spark-1.5.2-bin-hadoop2.6/bin/spark-submit --class NotSimpleApp --master spark://spark-master:7077 --driver-class-path postgresql-9.4-1203.jdbc4.jar --jars postgresql-9.4-1203.jdbc4.jar desh-streaming-job-assembly-1.0.jar topic_case_test34 local_mem_fs /mnt/storage/ /mnt/casefiles/ 10.0.2.15 10.0.2.15 9092 10.0.2.15 10 60

