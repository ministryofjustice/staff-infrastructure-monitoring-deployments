# Infrastructure Monitoring and Alerting Deployments


## About this repository

The IMA deployments repo holds the configuration for applications which are
deployed to the IMA platform using Helm/Kubernetes.

## Getting started
## Prerequisites:

1. Build your dev infrastructure using the [Staff Infrastructure Monitoring repo](https://github.com/ministryofjustice/staff-infrastructure-monitoring#5-set-up-your-own-development-infrastructure).

2. Export the terraform outputs in a json file

```sh
terraform output -json >> terraform_outputs.json
```

3. Copy that file in this repository and then run

```sh
export TERRAFORM_OUTPUTS=$(cat ./terraform_outputs.json)
```
## Usage

### Running the code for development

To deploy the charts in this repo, run 

```sh
make deploy-kubernetes
```

### Our other repositories

- [IMA Platform](https://github.com/ministryofjustice/staff-infrastructure-monitoring) - to monitor MoJ infrastructure and physical devices
- [Configuration](https://github.com/ministryofjustice/staff-infrastructure-monitoring-datasource-config) - to provision configuration for the IMA Platform
- [SNMP Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-snmpexporter) - to scrape data from physical devices (Docker image)
- [Blackbox Exporter](https://github.com/ministryofjustice/staff-infrastructure-monitoring-blackbox-exporter) - to probe endpoints over HTTP, HTTPS, DNS, TCP and ICMP.s (Docker image)
- [Metric Aggregation Server](https://github.com/ministryofjustice/staff-infrastructure-metric-aggregation-server) - to pull data from the SNMP exporter (Docker image)
- [Shared Services Infrastructure](https://github.com/ministryofjustice/staff-device-shared-services-infrastructure) - to manage our CI/CD pipelines

## License

[MIT License](LICENSE)
