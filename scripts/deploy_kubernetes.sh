#!/bin/bash

set -euo pipefail

get_outputs() {
  printf "\nFetching terraform outputs for $ENV\n\n"
  outputs=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value`
}

install_dependent_helm_chart() {
  helm repo add nginx-stable https://helm.nginx.com/stable
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo update
}

create_kubeconfig(){
  printf "\nCreating kubeconfig file\n\n"
  assume_role=$(echo $outputs | jq '.assume_role.value' | sed 's/"//g')
  TEMP_ROLE=`aws sts assume-role --role-arn $assume_role --role-session-name ci-authenticate-kubernetes-782`

  access_key=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
  secret_access_key=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
  session_token=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
  cluster_name=$(echo $outputs | jq  '.eks_cluster_id.value' | sed 's/"//g')

  AWS_ACCESS_KEY_ID=$access_key AWS_SECRET_ACCESS_KEY=$secret_access_key AWS_SESSION_TOKEN=$session_token aws eks\
    --region eu-west-2 update-kubeconfig --name $cluster_name --role-arn $assume_role
  chmod o-r $KUBECONFIG
  chmod g-r $KUBECONFIG
}

upgrade_auth_configmap(){
  printf "\nUpgrading cluster authentication configmap\n\n"
  cluster_role_arn=$(echo $outputs | jq '.eks_cluster_worker_iam_role_arn.value' | sed 's/"//g')
  helm upgrade --install --atomic mojo-$ENV-ima-configmap ./kubernetes/auth-configmap --set rolearn=$cluster_role_arn
}

deploy_nginx_ingress() {
  printf "\nInstalling/ upgrading NGINX Ingress chart\n\n"
  helm upgrade --install mojo-$ENV-ima-nginx-ingress nginx-stable/nginx-ingress
}

deploy_external_dns() {
  printf "\nInstalling/ upgrading external DNS chart\n\n"
  HOSTED_ZONE_DOMAIN=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value | jq .internal_hosted_zone_domain.value.name | sed 's/"//g'`

  helm upgrade --install mojo-$ENV-ima-external-dns bitnami/external-dns \
  --set provider=aws \
  --set source=ingress \
  --set domainFilters[0]=$HOSTED_ZONE_DOMAIN\
  --set policy=sync \
  --set registry=txt \
  --set interval=3m
}

get_cloudwatch_exporter_role_arns(){
  role_arn=`echo $outputs | jq -r .Parameter.Value | jq .cloudwatch_exporter_access_role_arns.value | sed 's/"//g'` || role_arn=""
  echo $role_arn
}

upgrade_ima_chart(){
  cluster_role_arn=$(echo $outputs | jq '.eks_cluster_worker_iam_role_arn.value' | sed 's/"//g')
  prometheus_thanos_storage_bucket_name=$(echo $outputs | jq '.prometheus_thanos_storage_bucket_name.value' | sed 's/"//g')
  prometheus_thanos_storage_kms_key_id=$(echo $outputs | jq '.prometheus_thanos_storage_kms_key_id.value' | sed 's/"//g')
  cloudwatch_exporter_access_role_arns=$(get_cloudwatch_exporter_role_arns | sed 's/,/\\,/g')

  printf "\nInstalling/ upgrading IMA Helm chart\n\n"
  helm upgrade --install mojo-$KUBERNETES_NAMESPACE-ima --namespace $KUBERNETES_NAMESPACE --create-namespace ./kubernetes/infrastructure-monitoring --set \
environment=$ENV,\
prometheus.image=$SHARED_SERVICES_ECR_BASE_URL/prometheus,\
alertmanager.image=prom/alertmanager,\
prometheusThanosStorageBucket.bucketName=$prometheus_thanos_storage_bucket_name,\
cloudwatchExporter.image=$SHARED_SERVICES_ECR_BASE_URL/cloudwatch-exporter,\
prometheusThanosStorageBucket.kmsKeyId=$prometheus_thanos_storage_kms_key_id,\
thanos.image=$SHARED_SERVICES_ECR_BASE_URL/thanos,\
cloudwatchExporter.accessRoleArns=$cloudwatch_exporter_access_role_arns,\
azure.devl.subscription_id=$DEVL_SUBSCRIPTION_ID,\
azure.devl.client_id=$DEVL_CLIENT_ID,\
azure.devl.client_secret=$DEVL_CLIENT_SECRET,\
azure.devl.tenant_id=$DEVL_TENANT_ID,\
azure.preprod.subscription_id=$PREPROD_SUBSCRIPTION_ID,\
azure.preprod.client_id=$PREPROD_CLIENT_ID,\
azure.preprod.client_secret=$PREPROD_CLIENT_SECRET,\
azure.preprod.tenant_id=$PREPROD_TENANT_ID,\
hosted_zone_domain=$HOSTED_ZONE_DOMAIN
}

get_prometheus_endpoint() {
  prometheus_endpoint=$(kubectl get ingress --namespace $KUBERNETES_NAMESPACE -o json | jq '.items[0].spec.rules[0].host')
  printf "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  printf "\nInternal prometheus endpoint: $prometheus_endpoint\n"
}

main(){
  export KUBECONFIG="./kubernetes/kubeconfig"

  get_outputs
  install_dependent_helm_chart
  create_kubeconfig
  upgrade_auth_configmap
  deploy_nginx_ingress
  deploy_external_dns
  upgrade_ima_chart
  get_prometheus_endpoint

  # Display all Pods
  printf "\nList of Pods:\n\n"
  kubectl get pods --namespace default
  kubectl get pods --namespace $KUBERNETES_NAMESPACE
}

main
