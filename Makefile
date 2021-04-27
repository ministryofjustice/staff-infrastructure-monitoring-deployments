#!make
include .env
export

deploy-kubernetes:
	THANOS_IMAGE_REPOSITORY_URL=$$THANOS_IMAGE_REPOSITORY_URL aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/deploy_kubernetes.sh

.PHONY: deploy-kubernetes
