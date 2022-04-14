{{ define "snmpexporterjobs.production" }}
- job_name: raritan_corsh
  honor_labels: true
  static_configs:
    - targets:
      # Corsham
      - {{ .Values.networkAddressCorsham }}.5 # MOJ-ARKC-SCON01
  metrics_path: /snmp
  params:
    module: [raritan_corsh]
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: '{{ .Values.snmpExporterLoadBalancer }}:9116' # SNMP exporter's hostname:port

- job_name: juniper_corsh
  honor_labels: true
  static_configs:
    - targets:
      # Corsham
      - {{ .Values.networkAddressCorsham }}.6 # MOJ-ARKC-SW03
      - {{ .Values.networkAddressCorsham }}.20 # MOJ-ARKC-SW01
      - {{ .Values.networkAddressCorsham }}.30 # MOJ-ARKC-SW02
  metrics_path: /snmp
  params:
    module: [juniper_corsh]
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: '{{ .Values.snmpExporterLoadBalancer }}:9116' # SNMP exporter's hostname:port

- job_name: paloalto_corsh
  honor_labels: true
  static_configs:
    - targets:
      # Corsham
      - {{ .Values.networkAddressCorsham }}.10 # MoJ-ARKC-FW01_A
      - {{ .Values.networkAddressCorsham }}.11 # MoJ-ARKC-FW01_B
  metrics_path: /snmp
  params:
    module: [paloalto_corsh]
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: '{{ .Values.snmpExporterLoadBalancer }}:9116' # SNMP exporter's hostname:port

- job_name: pa_corsh_mgmt
  honor_labels: true
  static_configs:
    - targets:
      # Corsham
      - {{ .Values.networkAddressCorsham }}.7 # MoJ-ARKC-FW02_A
      - {{ .Values.networkAddressCorsham }}.8 # MoJ-ARKC-FW02_B
  metrics_path: /snmp
  params:
    module: [pa_corsh_mgmt]
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: '{{ .Values.snmpExporterLoadBalancer }}:9116' # SNMP exporter's hostname:port

- job_name: raritan_farn
  honor_labels: true
  static_configs:
    - targets:
      # Farnborough
      - {{ .Values.networkAddressFarnborough }}.5 # MOJ-ARKF-SCON01
  metrics_path: /snmp
  params:
    module: [raritan_farn]
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: '{{ .Values.snmpExporterLoadBalancer }}:9116' # SNMP exporter's hostname:port

- job_name: juniper_farn
  honor_labels: true
  static_configs:
    - targets:
      # Farnborough
      - {{ .Values.networkAddressFarnborough }}.6 # MOJ-ARKF-SW03
      - {{ .Values.networkAddressFarnborough }}.20 # MOJ-ARKF-SW01
      - {{ .Values.networkAddressFarnborough }}.30 # MOJ-ARKF-SW02
  metrics_path: /snmp
  params:
    module: [juniper_farn]
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: '{{ .Values.snmpExporterLoadBalancer }}:9116' # SNMP exporter's hostname:port

- job_name: paloalto_farn
  honor_labels: true
  static_configs:
    - targets:
      # Farnborough
      - {{ .Values.networkAddressFarnborough }}.10 # MoJ-ARKF-FW01_A
      - {{ .Values.networkAddressFarnborough }}.11 # MoJ-ARKF-FW01_B
  metrics_path: /snmp
  params:
    module: [paloalto_farn]
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: '{{ .Values.snmpExporterLoadBalancer }}:9116' # SNMP exporter's hostname:port

- job_name: pa_farn_mgmt
  honor_labels: true
  static_configs:
    - targets:
      # Farnborough
      - {{ .Values.networkAddressFarnborough }}.7 # MoJ-ARKF-FW01_B
      - {{ .Values.networkAddressFarnborough }}.8 # MoJ-ARKF-FW02_B
  metrics_path: /snmp
  params:
    module: [pa_farn_mgmt]
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: '{{ .Values.snmpExporterLoadBalancer }}:9116' # SNMP exporter's hostname:port
{{ end }}