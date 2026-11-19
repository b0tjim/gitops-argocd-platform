CLUSTER_NAME ?= bakery-gitops

.PHONY: help cluster-up cluster-down

help: ## List the available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-14s %s\n", $$1, $$2}'

cluster-up: ## Create the local kind cluster
	kind create cluster --config kind/cluster.yaml --name $(CLUSTER_NAME) --wait 60s

cluster-down: ## Delete the local kind cluster
	kind delete cluster --name $(CLUSTER_NAME)
