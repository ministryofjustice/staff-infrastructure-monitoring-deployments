{{ define "cloudwatchMetrics.production" }}
discovery:
  exportedTagsOnMetrics:
    ec2:
      - Name
      - type
    ecs:
      - ClusterName
      - ServiceName
    s3:
      - BucketName
      - StorageType
  jobs:
  - type: AWS/EC2
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: CPUUtilization
        statistics: [Average]
        nilToZero: true
      - name: StatusCheckFailed
        statistics: [Average]
        nilToZero: true
      - name: StatusCheckFailed_Instance
        statistics: [Sum]
        nilToZero: true
      - name: StatusCheckFailed_System
        statistics: [Sum]
        nilToZero: true
      - name: NetworkIn
        statistics: [Average]
        nilToZero: true
      - name: NetworkOut
        statistics: [Average]
        nilToZero: true
      - name: NetworkPacketsIn
        statistics: [Average]
        nilToZero: true
      - name: DiskReadBytes
        statistics: [Average]
        nilToZero: true
      - name: DiskWriteBytes
        statistics: [Average]
        nilToZero: true
      - name: DiskReadOps
        statistics: [Average]
        nilToZero: true
      - name: DiskWriteOps
        statistics: [Average]
        nilToZero: true
  - type: AWS/ECS
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: CPUUtilization
        statistics: [Average, Minimum, Maximum]
        nilToZero: true
      - name: MemoryUtilization
        statistics: [Average]
        nilToZero: true
  - type: AWS/RDS
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: FreeStorageSpace
        statistics: [Average]
        nilToZero: true
      - name: ReadIOPS
        statistics: [Average]
        nilToZero: true
      - name: WriteIOPS
        statistics: [Average]
        nilToZero: true
      - name: CPUUtilization
        statistics: [Average]
        nilToZero: true
  - type: AWS/S3
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: BucketSizeBytes
        statistics: [Average]
        nilToZero: true
  - type: AWS/RDS
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: FreeStorageSpace
        statistics: [Average]
        nilToZero: true
      - name: ReadIOPS
        statistics: [Average]
        nilToZero: true
      - name: WriteIOPS
        statistics: [Average]
        nilToZero: true
      - name: CPUUtilization
        statistics: [Average]
        nilToZero: true
  - type: AWS/VPN
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: TunnelDataOut
        statistics: [Average]
        nilToZero: true
      - name: TunnelState
        statistics: [Average]
        nilToZero: true
      - name: TunnelDataIn
        statistics: [Average]
        nilToZero: true
  - type: AWS/SQS
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: NumberOfMessagesDeleted
        statistics: [Average]
        nilToZero: true
      - name: NumberOfMessagesReceived
        statistics: [Average, Maximum, Sum]
        nilToZero: true
      - name: NumberOfMessagesSent
        statistics: [Average, Sum]
        nilToZero: true
      - name: ApproximateAgeOfOldestMessage
        statistics: [Average]
        nilToZero: true
      - name: ApproximateNumberOfMessagesVisible
        statistics: [Average]
        nilToZero: true
      - name: ApproximateNumberOfMessagesNotVisible
        statistics: [Average]
        nilToZero: true
      - name: ApproximateNumberOfMessagesDelayed
        statistics: [Average]
        nilToZero: true
      - name: NumberOfEmptyReceives
        statistics: [Average]
        nilToZero: true
      - name: SentMessageSize
        statistics: [Average]
        nilToZero: true
  - type: AWS/Kinesis
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: GetRecords
        statistics: [teratorAgeMilliseconds, Sum]
        nilToZero: true
      - name: IncomingRecords
        statistics: [Sum]
        nilToZero: true
  - type: AWS/ApiGateway
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: 4XXError
        statistics: [Maximum]
        nilToZero: true
      - name: 5XXError
        statistics: [Maximum]
        nilToZero: true
      - name: IntegrationLatency
        statistics: [Maximum]
        nilToZero: true
      - name: Latency
        statistics: [Maximum]
        nilToZero: true
      - name: Count
        statistics: [Sum]
        nilToZero: true
  - type: AWS/Lambda
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: ConcurrentExecutions
        statistics: [Sum]
        nilToZero: true
      - name: Invocations
        statistics: [Sum]
        nilToZero: true
      - name: Errors
        statistics: [Sum]
        nilToZero: true
      - name: Throttles
        statistics: [Sum]
        nilToZero: true
  - type: ECS/ContainerInsights
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: RunningTaskCount
        statistics: [Average]
        nilToZero: true
  - type: Kea-DHCP-Service
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: pkt4-discover-received
        statistics: [Average]
        nilToZero: true
      - name: pkt4-offer-sent
        statistics: [Average]
        nilToZero: true
      - name: pkt4-request-received
        statistics: [Average]
        nilToZero: true
      - name: pkt4-ack-sent
        statistics: [Average]
        nilToZero: true
  - type: DNS-Bind-Server
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: CookieIn
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: CookieNew
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: Prefetch
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryAuthAns
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryDropped
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryDuplicate
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryNoauthAns
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryNXDOMAIN
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryNxrrset
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryRecursion
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryReferral
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QrySERVFAIL
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QrySuccess
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: QryUDP
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: RecursClients
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: ReqEdns0
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: Requestv4
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: RespEDNS0
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: Response
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
      - name: TruncatedResp
        statistics: [Average, Maximum, Minimum]
        nilToZero: true
  - type: Kea-DHCP
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: lease-percent-used
        statistics: [Average, Sum]
        nilToZero: true
      - name: STANDBY_WARN
        statistics: [Average, Sum]
        nilToZero: true
      - name: STANDBY_ERROR
        statistics: [Average, Sum]
        nilToZero: true
      - name: STANDBY_FATAL
        statistics: [Average, Sum]
        nilToZero: true
      - name: "Configuration successful"
        statistics: [Average, Sum]
        nilToZero: true
      - name: "Config reload failed"
        statistics: [Average, Sum]
        nilToZero: true
      - name: "STANDBY_Config reload failed"
        statistics: [Average, Sum]
        nilToZero: true
      - name: "STANDBY_Configuration successful"
        statistics: [Average, Sum]
        nilToZero: true
      - name: HA_SYNC_FAILED
        statistics: [Average, Sum]
        nilToZero: true
      - name: HA_HEARTBEAT_COMMUNICATIONS_FAILED
        statistics: [Average, Sum]
        nilToZero: true
      - name: STANDBY_HA_HEARTBEAT_COMMUNICATIONS_FAILED
        statistics: [Average, Sum]
        nilToZero: true
      - name: ALLOC_ENGINE_V4_ALLOC_ERROR
        statistics: [Average, Sum]
        nilToZero: true
      - name: ALLOC_ENGINE_V4_ALLOC_FAIL
        statistics: [Average, Sum]
        nilToZero: true
      - name: ALLOC_ENGINE_V4_ALLOC_FAIL_CLASSES
        statistics: [Average, Sum]
        nilToZero: true
      - name: STANDBY_ALLOC_ENGINE_V4_ALLOC_FAIL
        statistics: [Average, Sum]
        nilToZero: true
      - name: STANDBY_ALLOC_ENGINE_V4_ALLOC_FAIL_CLASSES
        statistics: [Average, Sum]
        nilToZero: true
      - name: pkt4-discover-received
        statistics: [Average, Sum]
        nilToZero: true
      - name: pkt4-offer-sent
        statistics: [Average, Sum]
        nilToZero: true
      - name: pkt4-request-received
        statistics: [Average, Sum]
        nilToZero: true
      - name: pkt4-ack-sent
        statistics: [Average, Sum]
        nilToZero: true
      - name: pkt4-nak-received
        statistics: [Average, Sum]
        nilToZero: true
      - name: pkt4-nak-sent
        statistics: [Average, Sum]
        nilToZero: true
      - name: pkt4-decline-received
        statistics: [Average, Sum]
        nilToZero: true
      - name: reclaimed-declined-addresses
        statistics: [Average, Sum]
        nilToZero: true
      - name: reclaimed-leases
        statistics: [Average, Sum]
        nilToZero: true
      - name: STANDBY_HA_SYNC_FAILED
        statistics: [Sum]
        nilToZero: true
  - type: AWS/NetworkELB
    regions: [eu-west-2]
    roleArns: [{{ .Values.cloudwatchExporter.accessRoleArns }}]
    length: 300
    metrics:
      - name: UnHealthyHostCount
        statistics: [Average, Sum]
        nilToZero: true
      - name: ProcessedBytes
        statistics: [Average]
        nilToZero: true
{{ end }}