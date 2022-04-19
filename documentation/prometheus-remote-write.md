# Prometheus Remote Write

## Table of contents

- [Prometheus Remote Write](#prometheus-remote-write)
  - [About Prometheus remote-write](#about-prometheus-remote-write)
  - [Making use of remote-write](#making-use-of-remote-write)
    - [The Config](#the-config)
    - [Visualising metrics in Grafana](#visualising-metrics-in-grafana)

## About Prometheus remote-write

Remote write is an out-of-the-box featre included with Prometheus that allows you to write metrics to a remote storage adapter. In our case [Thanos](https://thanos.io/).  We have implemented this to allow other teams to take advantage of the IMA platform, with minimal setup.  This also adds a layer of abstraction between collection/aggregation of metrics and storage/visualisation.

## Making use of remote-write

### Prerequisites

Before you start you should ensure that you have the following:
- A locally running prometheus, scraping metrics you find vauable
- Internet access for that instance.

### The Config

Include this config block in your prometheus.yaml

```yaml

remote_write:
  - url: <<REMOTE_WRITE_URL>> # The CloudOps team can provide you with this via the #ask-cloud-ops slack channel
    tls_config:
      insecure_skip_verify: true # This is only required when testing against the Development endpoint
    basic_auth:
        username: <<USERNAME>> # This will be provided alongside the REMOTE_WRITE_URL
        password: <<PASSWORD>> # As above
    metadata_config:
      send: false
```

### Visualising metrics in Grafana

Once the above config is in place, your metrics should appear in [Grafana](https://monitoring-alerting.staff.service.justice.gov.uk/) within 15m.  From there you can configure and provision dashboards using [these guides](https://github.com/ministryofjustice/staff-infrastructure-monitoring-config#integrating-with-the-platform)

