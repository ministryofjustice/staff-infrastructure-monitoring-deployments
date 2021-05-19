#!/bin/bash

set -euo pipefail

get_outputs() {
  printf "\nFetching terraform outputs for $ENV\n\n"
  outputs=`aws ssm get-parameter --name /terraform_staff_infrastructure_monitoring/$ENV/outputs | jq -r .Parameter.Value`
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

delete_workspace(){
  printf "\nDeleting namespace $KUBERNETES_NAMESPACE \n"
  kubectl delete namespace $KUBERNETES_NAMESPACE
}

main(){
  export KUBECONFIG="./kubernetes/kubeconfig"

  get_outputs
  create_kubeconfig
  delete_workspace
}

main
