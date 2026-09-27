# Cost and Design Considerations

This project is architecture-first, so the following are design considerations rather than deployment cost measurements.

## Main Cost Drivers

| Service | Main cost consideration |
|---|---|
| NAT Gateway | Hourly charge + processed data |
| RDS SQL Server | DB instance + storage + licensing |
| EC2 | Instance hours and attached storage |
| ALB | Load balancer hours + capacity units |
| CloudFront | Data transfer + requests |
| WAF | Web ACL + rules + requests |
| S3 | Storage + requests |
| CloudWatch | Metrics, logs, dashboards, alarms |
| SNS | Notifications |

## High Availability Trade-offs

The architecture uses one NAT Gateway per Availability Zone for AZ independence. This costs more than a single NAT Gateway but avoids making private application egress dependent on one AZ.

RDS Multi-AZ also increases database cost because a standby is maintained in another Availability Zone.

## Project Scope

Because the required deliverable is the architecture and documentation, cost values are intentionally not presented as deployment estimates.
