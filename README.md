# How to setup Istio AuthNZ mechanism to Kafka

The playground repo demos how Istio and Kafka can be integrated, leveraging Istio certificates for 
both authentication and authorization

## Prerequisites
- Docker
- Docker-compose
- Git

## Configuring Kafka Broker

For this configuration, we need to do one steps:
- Add our jar file to kafka lib folder.

## Starting an Istio and our Kafka Broker

For this example, we use a docker-compose file that setup server and create 3 accounts:
- consumer-kafka: for consumer container
- producer-kafka: for producer container
- broker-kafka: for interbroker authentication

The below commands will run:
- Zookeeper
- Kafka Broker
- Producer
- Consumer

### Run Kafka using Confluent official docker images

At the folder `kakfa-confluent` run the command:

```
docker-compose up
```
