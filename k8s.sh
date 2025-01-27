#!/bin/bash

export tolken=`cat /home/ubuntu/Documents/apache-spark-scala/spark-join/tolken.txt`
export caCertFile=/home/ubuntu/Documents/apache-spark-scala/spark-join/selfsigned_certificate.pem
export image_name=truong96/spark-k8s:latest

# Build
#sbt package

# JAR
export PATH_JAR_BUILD=/home/ubuntu/Documents/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar
export PATH_JAR_HDFS=hdfs://172.20.9.30:9000/tpch-5G/spark-tpc-h-queries_2.12-1.0.jar
hadoop fs -put -f $PATH_JAR_BUILD $PATH_JAR_HDFS

runSpark(){
  local delay=$1
  for ((j=1;j<=22;j++));
  do
    export APP_NAME="K8s warms Q$j - Delay $delay L3"
    spark-submit \
        --master k8s://https://172.20.80.100:6443  \
        --deploy-mode cluster \
        --executor-memory 12G \
        --total-executor-cores 55 \
        --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
        --conf spark.kubernetes.container.image=$image_name \
        --conf spark.kubernetes.authenticate.submission.caCertFile=$caCertFile \
        --conf spark.kubernetes.authenticate.submission.oauthToken=$tolken \
        --conf spark.shuffle.service.enabled=false \
        --conf spark.dynamicAllocation.shuffleTracking.enabled=true \
        --conf spark.dynamicAllocation.shuffleTracking.timeout=10000 \
        --conf spark.dynamicAllocation.enabled=true \
        --conf spark.dynamicAllocation.maxExecutors=10 \
        --conf spark.dynamicAllocation.minExecutors=5 \
        --conf spark.app.name="$APP_NAME" \
        --class "main.scala.TpchQuery" $PATH_JAR_HDFS $j

    echo "---------------------------------"
    echo "|    The system sleep $delay    |"
    echo "---------------------------------"
    sleep $delay

  done
}

runSpark 15
runSpark 30
runSpark 60