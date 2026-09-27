# ARAK AWS Architecture Diagrams

This directory contains the main visual solution architecture diagram and the two supporting diagrams used to explain the target design.

## Main Solution Architecture

![ARAK AWS Solution Architecture](./aws.jfif)

The main diagram represents the complete target solution architecture: public edge, VPC segmentation, two Availability Zones, ALB, EC2 Auto Scaling, RDS Multi-AZ, NAT gateways, security/management services, and monitoring.

The editable vector version is available as [aws.svg](./aws.svg), while the original visual version is displayed above.

The earlier visual version is also preserved in Git history: [view the original diagram](https://github.com/AhmedsaadyAS/arak-aws-saa-project/blob/8ae1ad017ba71700535d7df86e661373336e2aa8/ARCHITECTURE/diagrams/aws.jfif).

## Supporting Diagrams

### 1. VPC / Network Architecture

[Open network-architecture.svg](./network-architecture.svg)

Shows:

- VPC CIDR and Availability Zones
- Public, private application, and private database subnets
- Exact target-design CIDRs
- ALB and NAT Gateway placement
- EC2 Auto Scaling application tier
- RDS SQL Server database tier
- Private-subnet routing and controlled egress

### 2. Security & Traffic Flow

[Open security-traffic-flow.svg](./security-traffic-flow.svg)

Shows:

- Route 53 → CloudFront/WAF → ALB → EC2 → RDS traffic path
- Security-group relationships
- Private application and database boundaries
- IAM and Secrets Manager
- Systems Manager Session Manager
- NACLs and private-subnet controls
- CloudWatch and SNS monitoring/alerting

## Verified Architecture Values

- Region: `us-east-1`
- VPC: `arak-vpc` — `10.0.0.0/16`
- Public-A: `10.0.1.0/24`
- Public-B: `10.0.2.0/24`
- App-A: `10.0.11.0/24`
- App-B: `10.0.12.0/24`
- DB-A: `10.0.21.0/24`
- DB-B: `10.0.22.0/24`
- Application port: `5000`
- SQL Server port: `1433`
- Target-design ASG capacity: minimum 2, desired 2, maximum 6
- Target-design NAT: one gateway per Availability Zone
- RDS: SQL Server Standard Edition, private, Multi-AZ

## Request Path

```text
User
  -> Route 53
  -> CloudFront + WAF
  -> Application Load Balancer
  -> Target Group
  -> Private EC2 Auto Scaling Group
  -> React/Vite + Nginx / ASP.NET Core API
  -> RDS SQL Server
```

## Practical Evidence

The concrete deployed environment is documented separately under [DOCUMENTATION/practical-implementation.md](../../DOCUMENTATION/practical-implementation.md). That record preserves the actual deployed resource names and values used during validation.
