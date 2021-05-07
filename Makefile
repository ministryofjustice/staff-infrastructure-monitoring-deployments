#!make
include .env
export

deploy-kubernetes:
	SHARED_SERVICES_ECR_BASE_URL=$$SHARED_SERVICES_ECR_BASE_URL aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/deploy_kubernetes.sh

switch-to-namespace:
	aws-vault exec $$AWS_VAULT_PROFILE -- kubectl config set-context --currrent --namespace=$$KUBERNETES_NAMESPACE

.PHONY: deploy-kubernetes
