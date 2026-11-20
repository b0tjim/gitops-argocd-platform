CLUSTER_NAME ?= bakery-gitops

.PHONY: help cluster-up cluster-down argocd-install argocd-password

help: ## List the available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

cluster-up: ## Create the local kind cluster
	kind create cluster --config kind/cluster.yaml --name $(CLUSTER_NAME) --wait 60s

cluster-down: ## Delete the local kind cluster
	kind delete cluster --name $(CLUSTER_NAME)

argocd-install: ## Install the pinned ArgoCD release and wait for it to be ready
	kubectl apply --server-side --force-conflicts -k bootstrap/argocd
	kubectl -n argocd rollout status deployment/argocd-server --timeout=180s
	kubectl apply -f bootstrap/projects/

argocd-password: ## Print the initial ArgoCD admin password
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
