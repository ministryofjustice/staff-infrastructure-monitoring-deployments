#!/bin/bash

set -euo pipefail

get_outputs() {
  printf "\nFetching terraform outputs for $ENV\n\n"
  outputs=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value`
  network_services_outputs=`aws ssm get-parameter --name /codebuild/pttp-ci-infrastructure-net-svcs-core-pipeline/$ENV/terraform_outputs | jq -r .Parameter.Value`
  basic_auth_content=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/prometheus-basic-auth | jq -r .Parameter.Value`
  corsham_network_address=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/corsham-network-address | jq -r .Parameter.Value`
  farnborough_network_address=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/farnborough-network-address | jq -r .Parameter.Value`
  cloudwatch_exporter_access_role_arns=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/production/cloudwatch_exporter_access_role_arns | jq -r .Parameter.Value'`
}

install_dependent_helm_chart() {
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
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

create_basic_auth() {
  printf "\nCreating basic-auth secret\n\n"
  echo $basic_auth_content > auth
  kubectl delete secret basic-auth --namespace $KUBERNETES_NAMESPACE --ignore-not-found
  kubectl create secret generic basic-auth --from-file=./auth --namespace $KUBERNETES_NAMESPACE
}

upgrade_auth_configmap(){
  printf "\nUpgrading cluster authentication configmap\n\n"
  cluster_role_arn=$(echo $outputs | jq '.eks_cluster_worker_iam_role_arn.value' | sed 's/"//g')
  helm upgrade --install --atomic mojo-$ENV-ima-configmap ./kubernetes/auth-configmap --set rolearn=$cluster_role_arn
}

deploy_ingress_nginx() {
  printf "\nInstalling/ upgrading NGINX Ingress chart\n\n"
  helm upgrade --install mojo-$ENV-ima-ingress-nginx ingress-nginx/ingress-nginx
}

deploy_external_dns() {
  printf "\nInstalling/ upgrading external DNS chart\n\n"
  HOSTED_ZONE_PRIVATE=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value | jq .internal_hosted_zone_domain.value.name | sed 's/"//g'`
  HOSTED_ZONE_PUBLIC=`aws ssm get-parameter --name /codebuild/pttp-ci-ima-pipeline/$ENV/hosted-zone-public | jq -r .Parameter.Value`

  helm upgrade --install mojo-$ENV-ima-external-dns bitnami/external-dns \
  --set provider=aws \
  --set source=ingress \
  --set domainFilters[0]=$HOSTED_ZONE_PRIVATE\
  --set domainFilters[1]=$HOSTED_ZONE_PUBLIC\
  --set policy=sync \
  --set registry=txt \
  --set interval=3m
}

upgrade_ima_chart(){
  cluster_role_arn=$(echo $outputs | jq '.eks_cluster_worker_iam_role_arn.value' | sed 's/"//g')
  prometheus_thanos_storage_bucket_name=$(echo $outputs | jq '.prometheus_thanos_storage_bucket_name.value' | sed 's/"//g')
  prometheus_thanos_storage_kms_key_id=$(echo $outputs | jq '.prometheus_thanos_storage_kms_key_id.value' | sed 's/"//g')
  smtp_loadbalancer=$(echo $network_services_outputs | jq '.smtp_relay.monitoring_network_load_balancer.dns_name' | sed 's/"//g')
  blackbox_loadbalancer=$(echo $outputs | jq '.blackbox_exporter_hostname_v2.value' | sed 's/"//g' )
  snmp_loadbalancer=$(echo $outputs | jq '.snmp_exporter_hostname_v2.value' | sed 's/"//g' )

  printf "\nInstalling/ upgrading IMA Helm chart\n\n"
  helm upgrade --install mojo-$KUBERNETES_NAMESPACE-ima --namespace $KUBERNETES_NAMESPACE --create-namespace ./kubernetes/infrastructure-monitoring --set \
environment=$ENV,\
prometheus.image=$SHARED_SERVICES_ECR_BASE_URL/prometheus,\
configmap_reload.image=jimmidyson/configmap-reload,\
alertmanager.image=prom/alertmanager,\
prometheusThanosStorageBucket.bucketName=$prometheus_thanos_storage_bucket_name,\
cloudwatchExporter.image=$SHARED_SERVICES_ECR_BASE_URL/cloudwatch-exporter:v0.26.3-alpha,\
prometheusThanosStorageBucket.kmsKeyId=$prometheus_thanos_storage_kms_key_id,\
thanos.image=$SHARED_SERVICES_ECR_BASE_URL/thanos,\
cloudwatchExporter.accessRoleArns=$(echo $cloudwatch_exporter_access_role_arns | sed 's/,/\\,/g'),\
azure.devl.subscription_id=$DEVL_SUBSCRIPTION_ID,\
azure.devl.client_id=$DEVL_CLIENT_ID,\
azure.devl.client_secret=$DEVL_CLIENT_SECRET,\
azure.devl.tenant_id=$DEVL_TENANT_ID,\
azure.preprod.subscription_id=$PREPROD_SUBSCRIPTION_ID,\
azure.preprod.client_id=$PREPROD_CLIENT_ID,\
azure.preprod.client_secret=$PREPROD_CLIENT_SECRET,\
azure.preprod.tenant_id=$PREPROD_TENANT_ID,\
hosted_zone_private=$HOSTED_ZONE_PRIVATE,\
hosted_zone_public=$HOSTED_ZONE_PUBLIC,\
smtpexporter.loadbalancer=$smtp_loadbalancer,\
network_address.corsham=$corsham_network_address,\
network_address.farnborough=$farnborough_network_address,\
blackboxexporter.loadbalancer=$blackbox_loadbalancer,\
snmpexporter.loadbalancer=$snmp_loadbalancer
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
    create_basic_auth
    upgrade_auth_configmap
    deploy_ingress_nginx
    deploy_external_dns
    upgrade_ima_chart
    get_prometheus_endpoint

  # Display all Pods
  printf "\nList of Pods:\n\n"
  kubectl get pods --namespace default
  kubectl get pods --namespace $KUBERNETES_NAMESPACE
}

main
