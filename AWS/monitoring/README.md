# Monitoring and Observability

## Goal

Provide visibility into the health, performance, capacity, and availability of the Arak AWS architecture.

## CloudWatch Metrics

### Application / EC2

- CPUUtilization
- StatusCheckFailed
- Auto Scaling Group desired/current capacity

### Application Load Balancer

- RequestCount
- TargetResponseTime
- HTTPCode_Target_4XX_Count
- HTTPCode_Target_5XX_Count
- UnHealthyHostCount

### RDS

- CPUUtilization
- DatabaseConnections
- FreeStorageSpace
- FreeableMemory
- ReadIOPS
- WriteIOPS

## Recommended Alarms

| Alarm | Example condition | Purpose |
|---|---|---|
| EC2 High CPU | CPU > 70% | Capacity pressure |
| ALB Unhealthy Targets | UnHealthyHostCount > 0 | Application availability |
| ALB 5xx | Elevated target 5xx | Backend failure |
| ALB Latency | TargetResponseTime above threshold | Performance degradation |
| RDS CPU | CPU > 70% | Database pressure |
| RDS Connections | Connections above baseline | Connection exhaustion |
| RDS Free Storage | Below safe threshold | Storage risk |

Thresholds should be tuned to the application's normal workload.

## Auto Scaling Integration

The primary Auto Scaling policy uses target tracking on average EC2 CPU utilization at 50%.

Step scaling can be used for exceptional spikes with carefully separated thresholds. AWS recommends caution when combining target tracking and step scaling because conflicting policies can cause undesirable behavior.

## SNS

Amazon SNS receives notifications from important CloudWatch alarms.

Notification flow:

```text
CloudWatch Alarm
      |
      v
     SNS
      |
      v
Email / Operations Notification
```

## Dashboard

A project dashboard should group:

1. ALB traffic and errors
2. Target health
3. EC2 CPU and ASG capacity
4. RDS health and connections
5. Scaling events

## Logging

Application and infrastructure logs should be centralized in CloudWatch Logs where appropriate.

The design should avoid placing passwords, tokens, or other secrets in application logs.
