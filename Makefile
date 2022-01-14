#!make
include .env
export

deploy:
	./scripts/deploy_kubernetes.sh

remove-workspace:
	./scripts/remove_workspace.sh

get-pods:
	kubectl get pods --namespace $$KUBERNETES_NAMESPACE --kubeconfig="./kubernetes/kubeconfig" && \
	kubectl get pods --kubeconfig="./kubernetes/kubeconfig" 

get-services:
	kubectl get services --namespace $$KUBERNETES_NAMESPACE --kubeconfig="./kubernetes/kubeconfig" && \
	kubectl get services --kubeconfig="./kubernetes/kubeconfig" 

switch-to-namespace:
	aws-vault exec $$AWS_VAULT_PROFILE -- kubectl config set-context --currrent --namespace=$$KUBERNETES_NAMESPACE --kubeconfig="./kubernetes/kubeconfig" 

.PHONY: deploy get-pods get-services switch-to-namespace
