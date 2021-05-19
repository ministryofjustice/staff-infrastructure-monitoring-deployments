#!make
include .env
export

deploy:
	aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/deploy_kubernetes.sh

remove-workspace:
	aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/remove_workspace.sh

get-pods:
	aws-vault exec $$AWS_VAULT_PROFILE -- kubectl get pods --namespace $$KUBERNETES_NAMESPACE --kubeconfig="./kubernetes/kubeconfig" && \
	aws-vault exec $$AWS_VAULT_PROFILE -- kubectl get pods --kubeconfig="./kubernetes/kubeconfig" 

get-services:
	aws-vault exec $$AWS_VAULT_PROFILE -- kubectl get services --namespace $$KUBERNETES_NAMESPACE --kubeconfig="./kubernetes/kubeconfig" && \
	aws-vault exec $$AWS_VAULT_PROFILE -- kubectl get services --kubeconfig="./kubernetes/kubeconfig" 

switch-to-namespace:
	aws-vault exec $$AWS_VAULT_PROFILE -- kubectl config set-context --currrent --namespace=$$KUBERNETES_NAMESPACE --kubeconfig="./kubernetes/kubeconfig" 

.PHONY: deploy get-pods get-services switch-to-namespace
