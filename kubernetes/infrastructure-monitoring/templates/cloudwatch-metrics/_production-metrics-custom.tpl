{{ define "cloudwatchMetrics.production.custom" }}
- namespace: ECS/ContainerInsights
  name: "ECS - Container Insights"
  regions: [eu-west-2]
  length: 300
  metrics:
    - name: RunningTaskCount
      statistics: [Average]
      nilToZero: true
- namespace: DNS-Bind-Server
  name: "DNS Bind Server"
  regions: [eu-west-2]
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
- namespace: Kea-DHCP
  name: "Kea DHCP"
  regions: [eu-west-2]
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
{{ end }}