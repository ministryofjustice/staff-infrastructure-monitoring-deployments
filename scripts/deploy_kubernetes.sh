#!/bin/bash

set -euo pipefail

get_outputs() {
  printf "\nFetching terraform outputs for $ENV\n\n"
  outputs=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value`
  network_services_outputs=`aws ssm get-parameter --name /codebuild/pttp-ci-infrastructure-net-svcs-core-pipeline/$ENV/terraform_outputs | jq -r .Parameter.Value`
  basic_auth_content=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/prometheus-basic-auth | jq -r .Parameter.Value`
  corsham_network_address=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/corsham-network-address | jq -r .Parameter.Value`
  farnborough_network_address=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/farnborough-network-address | jq -r .Parameter.Value`
  cloudwatch_exporter_access_role_arns=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/production/cloudwatch_exporter_access_role_arns | jq -r .Parameter.Value`
  cloudwatch_exporter_development_arn=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/development/cloudwatch_exporter_access_role_arns | jq -r .Parameter.Value`
  cloudwatch_exporter_pre_production_arn=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/pre-production/cloudwatch_exporter_access_role_arns | jq -r .Parameter.Value`
  cloudwatch_exporter_production_arn=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/production/cloudwatch_exporter_access_role_arn | jq -r .Parameter.Value`
  cloudwatch_exporter_pki_arn=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/pki/cloudwatch_exporter_access_role_arns | jq -r .Parameter.Value`
  certificateAlertsSlackChannel=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/cert-slack-email | jq -r .Parameter.Value`
  letsencryptDirectoryUrl=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/$ENV/letsencrypt-url | jq -r .Parameter.Value`
  publicHostedZoneId=`aws ssm get-parameter --with-decryption --name /codebuild/pttp-ci-ima-pipeline/$ENV/public_hosted_zone_id | jq -r .Parameter.Value`
}

install_dependent_helm_chart() {
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo add jetstack https://charts.jetstack.io
  helm repo add stakater https://stakater.github.io/stakater-charts
  helm repo add eks https://aws.github.io/eks-charts
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

deploy_aws_vpc_cni() {
  helm upgrade -i aws-vpc-cni eks/aws-vpc-cni \
    --namespace kube-system \
    --set image.region=eu-west-2 \
    --set image.tag=v1.11.0 \
    --set init.image.region=eu-west-2 \
    --set init.image.tag=v1.11.0
}

create_kubernetes_namespace() {
  kubectl create namespace $KUBERNETES_NAMESPACE --dry-run=true -o yaml | kubectl apply -f -
}

create_basic_auth() {
  printf "\nCreating basic-auth secret\n\n"
  echo $basic_auth_content > auth
  kubectl delete secret basic-auth --namespace $KUBERNETES_NAMESPACE --ignore-not-found
  kubectl create secret generic basic-auth --from-file=./auth --namespace $KUBERNETES_NAMESPACE
}

authenticate_to_dockerhub() {
  if [[ -n "${DOCKER_USERNAME}" && -n "${DOCKER_PASSWORD}" ]]; then
    docker login --username ${DOCKER_USERNAME} --password ${DOCKER_PASSWORD}
  fi
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

deploy_cert_manager() {
  printf "\nInstalling/ upgrading cert-manager chart\n\n"
  helm upgrade --install mojo-$ENV-cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.8.0 \
  --set installCRDs=true
}

deploy_reloader() {
  printf "\nInstalling/ upgrading cert-manager chart\n\n"
  helm upgrade --install mojo-$ENV-reloader stakater/reloader 
}

deploy_external_dns() {
  printf "\nInstalling/ upgrading external DNS chart\n\n"
  hostedZonePrivate=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value | jq .internal_hosted_zone_domain.value.name | sed 's/"//g'`
  hostedZonePublic=`aws ssm get-parameter --name /codebuild/pttp-ci-ima-pipeline/$ENV/hosted-zone-public | jq -r .Parameter.Value`

  helm upgrade --install mojo-$ENV-ima-external-dns bitnami/external-dns \
  --set provider=aws \
  --set source=ingress \
  --set domainFilters[0]=$hostedZonePrivate\
  --set domainFilters[1]=$hostedZonePublic\
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
alertmanagerImage=prom/alertmanager:v0.24.0,\
blackboxExporterLoadBalancer=$blackbox_loadbalancer,\
certificateAlertsSlackChannel=$certificateAlertsSlackChannel,\
cloudwatchExporterAccessRoleArns=$(echo $cloudwatch_exporter_access_role_arns | sed 's/,/\\,/g'),\
cloudwatchExporterDevelopmentArn=$cloudwatch_exporter_development_arn,\
cloudwatchExporterPkiArn=$cloudwatch_exporter_pki_arn,\
cloudwatchExporterPreProductionArn=$cloudwatch_exporter_pre_production_arn,\
cloudwatchExporterProductionArn=$cloudwatch_exporter_production_arn,\
cloudwatchExporterImage=ghcr.io/nerdswords/yet-another-cloudwatch-exporter:v0.35.0-alpha,\
configmapReloadImage=jimmidyson/configmap-reload:v0.7.1,\
environment=$ENV,\
hostedZonePrivate=$hostedZonePrivate,\
hostedZonePublic=$hostedZonePublic,\
letsencryptDirectoryUrl=$letsencryptDirectoryUrl,\
networkAddressCorsham=$corsham_network_address,\
networkAddressFarnborough=$farnborough_network_address,\
prometheusImage=prom/prometheus:v2.21.0,\
publicHostedZoneId=$publicHostedZoneId,\
smtpExporterLoadBalancer=$smtp_loadbalancer,\
snmpExporterLoadBalancer=$snmp_loadbalancer,\
thanosImage=quay.io/thanos/thanos:v0.15.0,\
thanosStorageBucketName=$prometheus_thanos_storage_bucket_name,\
thanosStorageS3KmsKeyId=$prometheus_thanos_storage_kms_key_id
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
    deploy_aws_vpc_cni
    create_kubernetes_namespace
    create_basic_auth
    authenticate_to_dockerhub
    upgrade_auth_configmap
    deploy_reloader
    deploy_ingress_nginx
    deploy_external_dns
    deploy_cert_manager
    upgrade_ima_chart
    get_prometheus_endpoint


  # Display all Pods
  printf "\nList of Pods:\n\n"
  kubectl get pods --namespace default
  kubectl get pods --namespace $KUBERNETES_NAMESPACE
}

main
