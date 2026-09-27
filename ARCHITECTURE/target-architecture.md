# ARAK Target Solution Architecture

## Objective

Design a scalable, highly available AWS architecture for the existing Arak education-management SaaS application.

The architecture follows the selected Manara project:

**Project 1 – Scalable Web Application with ALB and Auto Scaling**

## Logical Architecture

```text
                         Internet Users
                              |
                              v
                         Amazon Route 53
                              |
                              v
                     CloudFront + AWS WAF
                        /              \
                       /                \
                      v                  v
              Amazon S3             Application
           React/Vite Frontend      Load Balancer
                                        |
                                        v
                                   Target Group
                                        |
                         +--------------+--------------+
                         |                             |
                         v                             v
                    EC2 / AZ-1                    EC2 / AZ-2
                         |                             |
                         +--------------+--------------+
                                        |
                                        v
                              ASP.NET Core API
                                        |
                                        v
                              Amazon RDS SQL Server
                             Multi-AZ private database
```

CloudFront supports multiple origins, including S3 and Application Load Balancers, making it suitable for separating static frontend delivery from dynamic API traffic while keeping a common public entry point.

## DNS and Edge Layer

### Route 53

Route 53 provides the public DNS entry for the application.

An alias record points the application domain to the CloudFront distribution. AWS documents Route 53 alias records as the standard way to route a domain to a CloudFront distribution.

### CloudFront

CloudFront provides:

- Global edge delivery
- Static asset caching
- TLS termination
- A common public entry point
- Separate origins for frontend and API traffic

### AWS WAF

WAF protects the public web layer with managed and application-specific rules.

Recommended rule categories:

- AWS Managed Rules
- Known bad input protection
- Common web exploit protection
- Rate-based protection for abusive request patterns

## VPC Design

**CIDR:** `10.0.0.0/16`

The VPC spans two Availability Zones.

| Tier | AZ-1 | AZ-2 | Purpose |
|---|---|---|---|
| Public | `10.0.1.0/24` | `10.0.2.0/24` | ALB and NAT Gateway |
| Private Application | `10.0.11.0/24` | `10.0.12.0/24` | EC2 Auto Scaling |
| Private Database | `10.0.21.0/24` | `10.0.22.0/24` | RDS |

### Public Subnets

Contain:

- Application Load Balancer
- NAT Gateway

Public route:

```text
0.0.0.0/0 -> Internet Gateway
```

### Private Application Subnets

Contain the EC2 Auto Scaling instances.

Each Availability Zone uses an AZ-local NAT Gateway for outbound Internet access.

### Private Database Subnets

Contain the RDS subnet group.

The database route tables contain the local VPC route only and do not provide direct Internet access.

## Application Tier

### EC2 Auto Scaling Group

The application tier is designed as replaceable compute.

- Launch Template
- Amazon Linux 2023
- Dockerized ASP.NET Core API
- Port `5000`
- Minimum capacity: 2
- Desired capacity: 2
- Maximum capacity: 6
- Health check type: ELB

The instances do not receive public IP addresses.

### Application Load Balancer

The ALB:

- Is internet-facing
- Runs across the two public subnets
- Receives HTTP/HTTPS traffic from the edge layer
- Routes API requests to the target group
- Performs health checks on `/health`
- Sends traffic only to healthy application targets

## Auto Scaling Strategy

### Primary Policy — Target Tracking

Target tracking maintains average EC2 CPU utilization around **50%**.

The Auto Scaling Group automatically adds capacity when demand increases and removes capacity when demand falls, within the configured minimum and maximum limits.

### Advanced Policy — Step Scaling

Step scaling is reserved for exceptional load thresholds where a more aggressive response is desirable.

Example design:

| Alarm condition | Adjustment |
|---|---:|
| CPU > 70% | +1 instance |
| CPU > 85% | +2 instances |

Scale-in should remain controlled by the primary target-tracking policy or by a separately designed scale-in mechanism to avoid conflicting instructions. AWS recommends caution when combining target tracking and step scaling.

## Database Tier

Amazon RDS for SQL Server provides the managed relational database layer.

Design:

- Private DB subnet group
- Two Availability Zones
- SQL Server Standard Edition
- Port `1433`
- Public accessibility disabled
- Encryption at rest
- Automated backups
- Multi-AZ deployment

RDS Multi-AZ uses a synchronized standby in another Availability Zone and can automatically fail over while preserving the database endpoint.

## Security Model

Traffic boundaries:

```text
Internet
   |
   v
CloudFront / WAF
   |
   v
ALB
   |
   v
Application EC2
   |
   v
RDS SQL Server
```

Security Groups:

- **ALB SG:** allow HTTP/HTTPS from the public edge.
- **App SG:** allow TCP `5000` only from ALB SG.
- **DB SG:** allow TCP `1433` only from App SG.

Additional controls:

- WAF at the web layer
- Private application subnets
- Private database subnets
- NACL defense in depth
- IAM roles
- Secrets Manager
- Systems Manager Session Manager

## Observability

CloudWatch monitors:

- EC2 CPU utilization
- Auto Scaling Group capacity
- ALB request count
- ALB HTTP 4xx/5xx
- ALB unhealthy hosts
- RDS CPU utilization
- RDS database connections
- RDS free storage

SNS distributes important alarm notifications.

## Availability Model

The solution removes major single-instance dependencies:

- ALB spans two AZs.
- Application instances span two AZs.
- Auto Scaling replaces unhealthy application instances.
- RDS uses Multi-AZ failover.
- NAT Gateway is deployed per AZ in the high-availability design.
- CloudFront distributes traffic through AWS edge locations.

## Operational Access

Systems Manager Session Manager is used for administration instead of exposing SSH to the public Internet.

The EC2 instance role provides the required AWS permissions without storing long-lived access keys on the instances.

## Design Outcome

The final solution separates:

1. DNS
2. Edge delivery and protection
3. Static frontend delivery
4. Load balancing
5. Replaceable application compute
6. Managed database
7. Monitoring and operations

This provides a clear, scalable architecture aligned with the selected SAA project scope.
