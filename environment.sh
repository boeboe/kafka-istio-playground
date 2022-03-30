#!/usr/bin/env bash

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${BASE_DIR}/helpers.sh

check_local_requirements

export CLUSTER_NAME=k3s-istio
export DOMAIN=kafka-tetrate.io

export ISTIO_VERSION=1.11.6
