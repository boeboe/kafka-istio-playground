#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

cd ${BASE_DIR}/certs

if [[ $1 = "root-ca" ]]; then
  make -f Makefile.selfsigned.mk root-ca
  print_info "Generated root certificate"
  exit 0
fi

if [[ $1 = "cluster" ]]; then
  make -f Makefile.selfsigned.mk ${CLUSTER_NAME}-cacerts
  print_info "Generated istio cluster certificate"
  exit 0
fi

if [[ $1 = "wildcard" ]]; then
  mkdir -p ./wildcard
  openssl req -out ./wildcard/${DOMAIN}.csr -newkey rsa:4096 -sha512 -nodes -keyout ./wildcard/${DOMAIN}.key -subj "/CN=*.${DOMAIN}/O=Istio"
  openssl x509 -req -sha512 -days 3650 -CA ./root-cert.pem -CAkey ./root-key.pem -set_serial "0x`openssl rand -hex 8`" -in ./wildcard/${DOMAIN}.csr -out ./wildcard/${DOMAIN}.pem -extfile <(printf "subjectAltName=DNS:${DOMAIN},DNS:*.${DOMAIN},DNS:localhost")
  cat ./wildcard/${DOMAIN}.pem ./root-cert.pem >> ./wildcard/${DOMAIN}-bundle.pem
  print_info "Generated wildcard certificate"
  exit 0
fi

if [[ $1 = "client" ]]; then
  mkdir -p ./client
  openssl req -out ./client/client.${DOMAIN}.csr -newkey rsa:4096 -sha512 -nodes -keyout ./client/client.${DOMAIN}.key -subj "/CN=client.${DOMAIN}/O=Client"
  openssl x509 -req -sha512 -days 3650 -CA ./root-cert.pem -CAkey ./root-key.pem -set_serial "0x`openssl rand -hex 8`" -in ./client/client.${DOMAIN}.csr -out ./client/client.${DOMAIN}.pem
  print_info "Generated client certificate"
  exit 0
fi

if [[ $1 = "kafka" ]]; then
  mkdir -p ./kafka
  openssl req -out ./kafka/kafka.${DOMAIN}.csr -newkey rsa:4096 -sha512 -nodes -keyout ./kafka/kafka.${DOMAIN}.key -subj "/CN=kafka.${DOMAIN}/O=Kafka"
  openssl x509 -req -sha512 -days 3650 -CA ./root-cert.pem -CAkey ./root-key.pem -set_serial "0x`openssl rand -hex 8`" -in ./kafka/kafka.${DOMAIN}.csr -out ./kafka/kafka.${DOMAIN}.pem
  print_info "Generated kafka broker certificate"
  exit 0
fi

if [[ $1 = "print-root-ca" ]]; then
  openssl x509 -in ./root-cert.pem -text
  exit 0
fi

if [[ $1 = "print-cluster" ]]; then
  openssl x509 -in ./${CLUSTER_NAME}/ca-cert.pem -text
  exit 0
fi

if [[ $1 = "print-wildcard" ]]; then
  openssl x509 -in ./wildcard/${DOMAIN}.pem -text
  openssl x509 -in ./wildcard/${DOMAIN}-bundle.pem -text
  exit 0
fi

if [[ $1 = "print-client" ]]; then
  openssl x509 -in ./client/client.${DOMAIN}.pem -text
  exit 0
fi

if [[ $1 = "print-kafka" ]]; then
  openssl x509 -in ./kafka/kafka.${DOMAIN}.pem -text
  exit 0
fi

if [[ $1 = "clean" ]]; then
  rm -rf ./client ./k3s-istio ./kafka ./wildcard
  rm root-*
  print_info "Cleaned generated certificates"
  exit 0
fi

print_error "Please specify correct option"
exit 1
