# Cloudwatch exporter

## Table of contents

- [Cloudwatch exporter](#azure-metrics-exporter)
  - [Table of contents](#table-of-contents)
  - [About Cloudwatch exporter](#about-azure-metrics-exporter)
  - [Deploy Cloudwatch exporter](#deploy-azure-metrics-exporter)
    - [Prerequisites](#prerequisites)
    - [Adding AWS Metrics](#adding-aws-metrics)
    - [Adding Custom Metrics](#adding-custom-metrics)
    - [Notes about deployment](#notes-about-deployment)

## About Cloudwatch exporter

Cloudwatch exporter is an unofficial exporter for [Prometheus](https://prometheus.io/) which allows metrics from Cloudwatch to be exported by Prometheus.  We use [YACE](https://github.com/nerdswords/yet-another-cloudwatch-exporter). 

| :exclamation: IMPORTANT          |
|:---------------------------|
| Cloudwatch exporter relies on resources being tagged properly in AWS.  If your resources aren't tagged, they won't be picked up by the exporter.     |


| :exclamation: IMPORTANT          |
|:---------------------------|
| Custom metrics, i.e anything outside of the standard AWS offering are only available for production and pre-production workloads.   |

Please follow the guide below to make changes to Cloudwatch exporter:

## Editing Cloudwatch exporter

### Prerequisites

Before you start you should ensure that you have the following:
- Details of the metrics you want to configure.
- Access to this Github repository with neccessary access permission to be able to push code changes to a branch.

### Adding AWS Metrics

Edit the [_default-metrics.tpl](kubernetes/infrastructure-monitoring/templates/cloudwatch-metrics/_default-metrics.tpl) and add a new job using the below format.
```yaml

  - type: AWS/RDS #(metric namespace)
    regions:
      - eu-west-2
    metrics:
      - name: FreeStorageSpace #(metric name)
        statistics:
          - Average
          - Minimum
          - Maximum
        nilToZero: true
        period: 600
        length: 300
```
---
**Important**

Be sure that the metric namespace you want to add doesn't exist already! If it doesn't simply add your required metric in the `metrics` block of that namespace.

---
<br>

### Adding Custom Metrics

Metrics outside of the standard Cloudwatch offering must be added as part of a static config block in the [_production-metrics-custom.tpl](kubernetes/infrastructure-monitoring/templates/cloudwatch-metrics/_production-metrics-custom.tpl) file.

The syntax is slightly _different_ but very similar to the standard config.

```yaml
- namespace: Kea-DHCP # Your custom Cloudwatch Namespace
  name: "Kea DHCP" # visible name
  regions: [eu-west-2]
  roleArns: [{{ .Values.cloudwatchExporterAccessRoleArns }}]
  metrics:
  - name: STANDBY_WARN # Metric name
    statistics: [Average, Sum, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: STANDBY_ERROR
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300 
```

### Notes about deployment

There is no automatic reload in place for Cloudwatch exporter at the moment (it is in our backlog).  This means if you do add additional metrics, please let a member of the CloudOps team know so they can reload the pod for you.
