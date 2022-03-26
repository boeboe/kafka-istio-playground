#!/usr/bin/env bash

echo "kafkacat -P -b ${KAFKA_BROKERS} -t ${KAFKA_TOPIC} -T -l /tmp/msgs -K:"

i=0
while true
do 
  echo -e ${i}:$(date +"%Y-%m-%dT%H:%M:%S") > /tmp/msgs
  kafkacat -P -b ${KAFKA_BROKERS} -t ${KAFKA_TOPIC} -T -l /tmp/msgs -K:
  sleep 1
  let "i=i+1"
done
