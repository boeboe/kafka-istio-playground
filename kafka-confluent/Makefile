# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

kafka-up: ## Start kafka cluster
	docker-compose -f kafka-cluster/docker-compose.yaml up

kafka-down: ## Stop kafka cluster
	docker-compose -f kafka-cluster/docker-compose.yaml down -v

consumer-up: ## Start kafka consumer
	docker-compose -f consumer/docker-compose.yaml up

consumer-down: ## Stop kafka consumer
	docker-compose -f consumer/docker-compose.yaml down -v


producer-up: ## Start kafka producer
	docker-compose -f producer/docker-compose.yaml up

producer-down: ## Stop kafka producer
	docker-compose -f producer/docker-compose.yaml down -v

k3s-up: ## Start k3s cluster
	docker-compose -f k3s-cluster/docker-compose.yaml up

k3s-down: ## Stop k3s cluster
	docker-compose -f k3s-cluster/docker-compose.yaml down -v

