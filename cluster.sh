#!/bin/bash

export TPCH_INPUT_DATA_DIR="hdfs://172.20.9.30:9000/tpch-5G/"
export TPCH_QUERY_OUTPUT_DIR="hdfs://172.20.9.30:9000/tpch-5G/output"
export TPCH_EXECUTION_TIMES="hdfs://172.20.9.30:9000/tpch-5G/execution_times"

# Build
sbt package

# JAR
export PATH_JAR_BUILD=/home/ubuntu/Documents/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar
export PATH_JAR_HDFS=hdfs://172.20.9.30:9000/tpch-5G/spark-tpc-h-queries_2.12-1.0.jar
hadoop fs -put -f $PATH_JAR_BUILD $PATH_JAR_HDFS

runSpark(){
  local delay=$1
  for ((j=1;j<=22;j++));
  do
    export APP_NAME="Cluster Q$j - Delay $delay L1"
    spark-submit \
    --master spark://172.20.80.100:7077 \
    --conf spark.dynamicAllocation.executorIdleTimeout=10000 \
    --executor-memory 12G \
    --total-executor-cores 55 \
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