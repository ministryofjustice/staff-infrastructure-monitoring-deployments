# Infrastructure Monitoring and Alerting Deployments

## Table of contents

- [About this repository](#about-this-repository)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Set up AWS Vault](#set-up-aws-vault)
- [Usage](#usage)
  - [Deploy to your namespace](#deploy-to-your-namespace)
  - [Azure metrics exporter](documentation/azure-metrics-exporter.md)
  - [Removing your namespace and associated resources](#removing-your-namespace-and-associated-resources)
- [Other Documentation](#other-documentation)
- [Our other repositories](#our-other-repositories)
- [License](#license)

## About this repository

The IMA deployments repo holds the configuration for applications which are
deployed to the IMA platform using Helm/Kubernetes. See the [IMA Platform infrastructure repository](https://github.com/ministryofjustice/staff-infrastructure-monitoring) for information on the platform as a whole.

## Getting started
### Prerequisites:

Before you start you should ensure that you have installed the following:
- [AWS Vault](https://github.com/99designs/aws-vault) (>= 6.0.0) - to easily manage and switch between AWS account profiles on the command line
- [helm](https://helm.sh/docs/intro/install/) - to manage kubernetes deployments
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - to manage kubernetes resources

### Set up AWS Vault
To set up AWS Vault follow the instructions [here.](https://github.com/ministryofjustice/staff-infrastructure-monitoring#1-set-up-aws-vault)

## Usage

### Deploy to your namespace
This will deploy prometheus, thanos, cloudwatch & azure metrics exporters to the development EKS cluster in a dedicated namespace.

1. Deploy the alerting configuration charts in [Staff Infrastructure Monitoring Config repo](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config#ima-development).

2. Create a `.env` file.

```sh
cp `.env.example` `.env`
```
3. Modify the `.env` file and replace all necessary values. `KUBERNETES_NAMESPACE` should match the namespace name you used in the [configuration repository](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config).
4. Deploy the charts in this repo by running

```sh
make deploy
```

5. The script will output a prometheus endpoint. You can use this endpoint when adding a prometheus data source in the development grafana instance.

### Removing your namespace and associated resources
This will delete your namespace on the cluster and all pods/services etc. associated with it. Included the alerting configuration which is deployed from the [Staff Infrastructure Monitoring Config repo](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config).

```sh
  make remove-workspace
```

## Other Documentation

- [Azure metrics exporter](documentation/azure-metrics-exporter.md)

## Our other repositories

- [IMA Platform](https://github.com/ministryofjustice/staff-infrastructure-monitoring) - to monitor MoJ infrastructure and physical devices
- [Configuration](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config) - to provision configuration for the IMA Platform
- [SNMP Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-snmpexporter) - to scrape data from physical devices (Docker image)
- [Blackbox Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-blackbox-exporter) - to probe endpoints over HTTP, HTTPS, DNS, TCP and ICMP.s (Docker image)
- [Metric Aggregation Server](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server) - to pull data from the SNMP exporter (Docker image)
- [Shared Services Infrastructure](https://github.com/ministryofjustice/staff-device-shared-services-infrastructure) - to manage our CI/CD pipelines

## License

[MIT License](LICENSE)
