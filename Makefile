# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

KAFKA_FLAVOUR	:= kafka-confluent

generate-certs: ## Generate certificates
	cd certs && \
	./certs.sh root-ca && \
	./certs.sh cluster && \
	./certs.sh wildcard && \
	./certs.sh client && \
	./certs.sh kafka

clean-certs: ## Clean-up certificates
	cd certs && ./certs.sh clean

setup-up: ## Start local setup
	${KAFKA_FLAVOUR}/setup.sh docker-compose-up

setup-down: ## Stop local setup
	${KAFKA_FLAVOUR}/setup.sh docker-compose-down

install-istio-certs:
	${KAFKA_FLAVOUR}/setup.sh install-istio-certs

patch-coredns:
	${KAFKA_FLAVOUR}/setup.sh patch-coredns

install-istio: install-istio-certs patch-coredns ## Install istio
	${KAFKA_FLAVOUR}/setup.sh install-istio

install-kafka-consumer-producer: ## Install kafka consumer and producer
	${KAFKA_FLAVOUR}/setup.sh install-kafka-consumer-producer

install-network-multitool: ## Install network multitool
	${KAFKA_FLAVOUR}/setup.sh install-network-multitool
