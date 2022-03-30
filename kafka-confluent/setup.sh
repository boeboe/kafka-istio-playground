#!/usr/bin/env bash

set -o xtrace

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

if [[ $1 = "install-istio" ]]; then
  print_info "Switching to istio ${ISTIO_VERSION}, flavor ${ISTIO_FLAVOR}"
  getmesh switch ${ISTIO_VERSION} --flavor ${ISTIO_FLAVOR}

  print_info "Install istio in k3s cluster"
  istioctl install -y --set profile=default -f${ISTIO_CONF_DIR}/cluster-operator.yaml

  k wait --timeout=5m --for=condition=Ready pods --all -n istio-system

  print_info "Istio installed"
  exit 0
fi


if [[ $1 = "info-istio" ]]; then
  print_info "Get istio info"
  k get po,svc -n istio-system -o wide
  exit 0
fi

print_error "Please specify correct option"
exit 1