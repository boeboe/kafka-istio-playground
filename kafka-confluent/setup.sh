#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

KUBECONFIG=${BASE_DIR}/kafka-confluent/output/kubeconfig.yaml
ISTIO_CERT_DIR=${BASE_DIR}/certs/${CLUSTER_NAME}
ISTIO_CONF_DIR=${BASE_DIR}/istio

shopt -s expand_aliases
alias k="kubectl --kubeconfig=${KUBECONFIG}"
alias istioctl="istioctl --kubeconfig ${KUBECONFIG}"


if [[ $1 = "docker-compose-up" ]]; then
  print_info "Going to start docker compose environment"
  docker-compose -f ${BASE_DIR}/kafka-confluent/docker-compose.yaml up
  exit 0
fi

if [[ $1 = "docker-compose-down" ]]; then
  docker-compose -f ${BASE_DIR}/kafka-confluent/docker-compose.yaml down -v
  print_info "Docker compose environment cleaned up"
  exit 0
fi

if [[ $1 = "install-istio-certs" ]]; then
  if ! k get ns istio-system; then k create ns istio-system; fi

  if ! k -n istio-system get secret cacerts; then
    k create secret generic cacerts -n istio-system \
    --from-file=${ISTIO_CERT_DIR}/ca-cert.pem \
    --from-file=${ISTIO_CERT_DIR}/ca-key.pem \
    --from-file=${ISTIO_CERT_DIR}/root-cert.pem \
    --from-file=${ISTIO_CERT_DIR}/cert-chain.pem
  fi

  print_info "Certificates installed"
  exit 0
fi

if [[ $1 = "patch-coredns" ]]; then
cat <<EOF | tee ${BASE_DIR}/kafka-confluent/output/coredns-patch.yaml
data:
  NodeHosts: |
    $(docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" k3s-server) k3s-server
    $(docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" k3s-agent) k3s-agent
    $(docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" kafka) kafka
    $(docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" zookeeper) zookeeper
    $(docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" kafdrop) kafdrop
EOF

  k patch configmap/coredns --patch-file ${BASE_DIR}/kafka-confluent/output/coredns-patch.yaml -n kube-system 
  k delete pod $(k get pod -n kube-system -l k8s-app=kube-dns -o jsonpath='{.items[0].metadata.name}') -n kube-system 
  print_info "Coredns configmap patched and coredns pod restarted"
  exit 0
fi

if [[ $1 = "install-istio" ]]; then
  print_info "Install istio in k3s cluster"
  istioctl install -y --set profile=default -f${ISTIO_CONF_DIR}/cluster-operator.yaml

  k wait --timeout=5m --for=condition=Ready pods --all -n istio-system

  print_info "Istio installed"
  exit 0
fi

if [[ $1 = "install-kafka-consumer-producer" ]]; then
  k apply -f ${ISTIO_CONF_DIR}/namespaces.yaml
  k apply -f ${ISTIO_CONF_DIR}/kafka-consumer.yaml
  k apply -f ${ISTIO_CONF_DIR}/kafka-producer.yaml

  k wait --timeout=5m --for=condition=Ready pods --all -n kafka-consumer
  k wait --timeout=5m --for=condition=Ready pods --all -n kafka-producer

  print_info "Kafka consumer and producer installed"
  exit 0
fi

if [[ $1 = "install-network-multitool" ]]; then
  k apply -f ${ISTIO_CONF_DIR}/network-multitool.yaml

  k wait --timeout=5m --for=condition=Ready pods --all -n default

  print_info "Network multitool installed"
  exit 0
fi


if [[ $1 = "info-istio" ]]; then
  print_info "Get istio info"
  k get po,svc -n istio-system -o wide
  exit 0
fi

print_error "Please specify correct option"
exit 1