#!make
include .env
export

deploy-kubernetes:
	aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/deploy_kubernetes.sh

.PHONY: deploy-kubernetes
