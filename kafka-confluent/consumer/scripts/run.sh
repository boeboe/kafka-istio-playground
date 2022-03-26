#!/usr/bin/env bash

echo "kafkacat -C -b ${KAFKA_BROKERS} -t ${KAFKA_TOPIC} -o -1 -c 1 -e -K:"

while true
do 
  kafkacat -C -b ${KAFKA_BROKERS} -t ${KAFKA_TOPIC} -o -1 -c 1 -e -J
  sleep 1
done
