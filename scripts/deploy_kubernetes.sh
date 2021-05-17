#!/bin/bash

set -euo pipefail

get_outputs() {
  echo `aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value`
}

create_kubeconfig(){
  echo "Creating kubeconfig file"
  outputs=$(get_outputs)

  assume_role=$(echo $outputs | jq '.assume_role.value' | sed 's/"//g')
  TEMP_ROLE=`aws sts assume-role --role-arn $assume_role --role-session-name ci-authenticate-kubernetes-782`

  access_key=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
  secret_access_key=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
  session_token=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
  cluster_name=$(echo $outputs | jq  '.eks_cluster_id.value' | sed 's/"//g')

  AWS_ACCESS_KEY_ID=$access_key AWS_SECRET_ACCESS_KEY=$secret_access_key AWS_SESSION_TOKEN=$session_token aws eks\
    --region eu-west-2 update-kubeconfig --name $cluster_name --role-arn $assume_role
}

upgrade_auth_configmap(){
  outputs=$(get_outputs)
  cluster_role_arn=$(echo $outputs | jq '.eks_cluster_worker_iam_role_arn.value' | sed 's/"//g')
  echo "Deploying auth configmap"
  helm upgrade --install --atomic mojo-$ENV-ima-configmap ./kubernetes/auth-configmap --set rolearn=$cluster_role_arn
}

get_cloudwatch_exporter_role_arns(){
  outputs=$(get_outputs)
  role_arn=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value | jq .cloudwatch_exporter_access_role_arns.value | sed 's/"//g'`\
    || role_arn=""
  echo $role_arn
}

deploy_nginx_ingress() {
  echo "Deploying NGINX Ingress"
  helm repo add nginx-stable https://helm.nginx.com/stable
  helm repo update
  helm upgrade --install mojo-$ENV-ima-nginx-ingress nginx-stable/nginx-ingress
}

deploy_external_dns() {
  echo "getting hosted zone domain"
  HOSTED_ZONE_DOMAIN=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value | jq .internal_hosted_zone_domain.value.name | sed 's/"//g'`
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo update

  helm upgrade --install mojo-$ENV-ima-external-dns bitnami/external-dns \
  --set provider=aws \
  --set source=ingress \
  --set domainFilters[0]=$HOSTED_ZONE_DOMAIN\
  --set policy=sync \
  --set registry=txt \
  --set interval=3m
}

upgrade_ima_chart(){
  outputs=$(get_outputs)
  cluster_role_arn=$(echo $outputs | jq '.eks_cluster_worker_iam_role_arn.value' | sed 's/"//g')
  prometheus_thanos_storage_bucket_name=$(echo $outputs | jq '.prometheus_thanos_storage_bucket_name.value' | sed 's/"//g')
  prometheus_thanos_storage_kms_key_id=$(echo $outputs | jq '.prometheus_thanos_storage_kms_key_id.value' | sed 's/"//g')
  cloudwatch_exporter_access_role_arns=$(get_cloudwatch_exporter_role_arns | sed 's/,/\\,/g')

  echo "Deploying IMA Helm chart"
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
hosted_zone_domain=$HOSTED_ZONE_DOMAIN
}

main(){
  export KUBECONFIG="./kubernetes/kubeconfig"

  create_kubeconfig
  upgrade_auth_configmap
  deploy_nginx_ingress
  deploy_external_dns
  upgrade_ima_chart

  # Display all Pods
  echo "List of Pods:"
  kubectl get pods --namespace $KUBERNETES_NAMESPACE
}

main
