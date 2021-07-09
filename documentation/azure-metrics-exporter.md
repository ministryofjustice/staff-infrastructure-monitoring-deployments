# Azure metrics exporter

## Table of contents

- [Azure metrics exporter](#azure-metrics-exporter)
  - [Table of contents](#table-of-contents)
  - [About Azure metrics exporter](#about-azure-metrics-exporter)
  - [Deploy Azure metrics exporter](#deploy-azure-metrics-exporter)
    - [Prerequisites](#prerequisites)
    - [Prepare the Azure tenant](#prepare-the-azure-tenant)
    - [Add secrets in AWS Parameter Store](#add-secrets-in-aws-parameter-store)
    - [Add deployment templates in this repo](#add-deployment-templates-in-this-repo)

## About Azure metrics exporter

Azure metrics exporter is an unofficial exporter for [Prometheus](https://prometheus.io/) which allows metrics from Azure applications to be exported by Prometheus using [Azure monitor API](https://docs.microsoft.com/en-us/azure/monitoring-and-diagnostics/monitoring-rest-api-walkthrough). This exporter is a third-party managed exporter. More information can be found [here](https://github.com/RobustPerception/azure_metrics_exporter). The supported metrics with Azure Monitor can be found [here](https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported)

| :exclamation: IMPORTANT          |
|:---------------------------|
| A single instance of Azure metrics exporter can export metrics from only one Azure tenant. Therefore in order to start exporting metrics from a new Azure tenant, deployment of a new instance of Azure metrics exporter is required.     |

Please follow the guide below to deploy an Azure metrics exporter:

## Deploy Azure metrics exporter

### Prerequisites

Before you start you should ensure that you have the following:
- Full administrative access to the Azure tenant that you are deploying the exporter for. You should be able to view all the Azure subscriptions in that tenant and be able to make changes to the access control (IAM) of the subscription.
- Access to AWS Shared Services account with neccessary access permission to create new secrets in [AWS Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html).
- Access to this Github repository with neccessary access permission to be able to push code changes to a branch.

### Prepare the Azure tenant

:white_square_button: Register a new app in Azure Active Directory:

  | :large_orange_diamond:        | Azure Active Directory :arrow_right: App registration :arrow_right: New registration       |
  |---------------|:------------------------|

:white_square_button: Assign 'Monitoring Reader' role to the newly registered app:

  | :large_orange_diamond:        | Subscription :arrow_right: your_subscription :arrow_right: Access Control (IAM) :arrow_right: Role assignments :arrow_right: Add  :arrow_heading_down:     |
  |---------------|:------------------------|
  |  | Role: 'Monitoring Reader' :heavy_plus_sign: Select: your_newly_registered_app  |

:exclamation: Take a note of the following items from this Azure tenant for the next step:
  - Azure subscription ID
  - Client ID
  - Tenant ID
  - Client Secret

### Add secrets in AWS Parameter Store

:white_square_button: Log on to AWS Shared Services account and add the values of the noted items from the previous step in AWS Parameter Store as secrets. Please follow the below pattern to name the secrets:
  - `/codebuild/pttp-ci-ima-pipeline/<your_tenant_short_name>-subscription-id` for the Azure subscription ID
  - `/codebuild/pttp-ci-ima-pipeline/<your_tenant_short_name-client-id` for the client ID
  - `/codebuild/pttp-ci-ima-pipeline/<your_tenant_short_name-tenant-id` for the tenant ID
  - `	/codebuild/pttp-ci-ima-pipeline/<your_tenant_short_name-client-secret` for the client secret

  ### Add deployment templates in this repo

  :white_square_button: Clone this repo
  :white_square_button: Add `configmap.yaml`
  :white_square_button: Add `deployment.yaml`
  :white_square_button: Add `service.yaml`
  :white_square_button: Add new placeholders in `values.yaml`
  :white_square_button: Add the values in `.env` file
  :white_square_button: Update the `.env.example` for other developers
  :white_square_button: Add the values in `buildspec.yml` file
  :white_square_button: Update the `deploy_kubernetes.sh` script in scripts folder to pass the values in for the placeholders during deployment
  :white_square_button: Create a new branch for this change
  :white_square_button: Commit the changes and push it to the branch
  :white_square_button: Raise a PR and notify the IMA team.
  :heavy_check_mark: Done