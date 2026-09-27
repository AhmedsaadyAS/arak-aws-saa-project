# Arak AWS Solutions Architect – Associate Project

AWS Solutions Architect – Associate graduation project based on the Arak education-management SaaS application.

## Project

**Manara Project 1 – Scalable Web Application with ALB and Auto Scaling**

The goal of this repository is to document a complete AWS solution architecture for Arak. The project focuses on architecture design, service selection, network segmentation, security, availability, scalability, observability, and operational considerations.

A live deployment is not required for the project deliverable. The repository therefore presents the **designed solution architecture** rather than a deployment-status report.

## Solution Architecture

![ARAK AWS Solution Architecture](ARCHITECTURE/diagrams/aws.jfif)

The architecture uses:

- Amazon Route 53 for DNS
- Amazon CloudFront for global delivery and static-content caching
- AWS WAF for web-layer protection
- Amazon S3 for the React/Vite static frontend
- Internet-facing Application Load Balancer for API traffic
- Amazon EC2 Auto Scaling across two Availability Zones
- Dockerized ASP.NET Core API
- Amazon RDS for SQL Server in private database subnets
- NAT Gateway for controlled private-subnet egress
- IAM roles, AWS Secrets Manager, and Systems Manager
- Amazon CloudWatch and Amazon SNS for monitoring and alerting

## Request Flow

### Frontend

```text
User
  |
  v
Route 53
  |
  v
CloudFront + WAF
  |
  v
S3
  |
  v
React/Vite Frontend
```

### API

```text
User / Frontend
      |
      v
Route 53
      |
      v
CloudFront + WAF
      |
      v
Application Load Balancer
      |
      v
Target Group
      |
      v
EC2 Auto Scaling Group
      |
      v
ASP.NET Core API
      |
      v
Amazon RDS for SQL Server
```

CloudFront can use multiple origins, including Amazon S3 and an Application Load Balancer, which allows the frontend and API paths to share the same public entry point.

## Network Design

**Region:** `us-east-1`  
**VPC CIDR:** `10.0.0.0/16`

| Tier | AZ-1 | AZ-2 | Purpose |
|---|---|---|---|
| Public | `10.0.1.0/24` | `10.0.2.0/24` | ALB and NAT Gateway |
| Private Application | `10.0.11.0/24` | `10.0.12.0/24` | EC2 Auto Scaling |
| Private Database | `10.0.21.0/24` | `10.0.22.0/24` | RDS subnet group |

The ALB is placed in public subnets. Application instances and the database remain private. Application subnets use NAT Gateway for controlled outbound access, while database subnets do not have a direct Internet route.

For the high-availability design, one NAT Gateway is placed in each Availability Zone.

## Security Architecture

Traffic is restricted layer by layer:

```text
Internet
   |
   v
CloudFront / WAF
   |
   v
ALB Security Group
   |
   v
Application Security Group
   |
   v
Database Security Group
```

Key controls:

- WAF protects the public web layer.
- ALB accepts web traffic and forwards only approved application traffic.
- EC2 instances have no public IP addresses.
- Application port `5000` is reachable only from the ALB security group.
- SQL Server port `1433` is reachable only from the application security group.
- Database credentials are stored in Secrets Manager.
- IAM roles are used instead of long-lived AWS access keys.
- Systems Manager Session Manager provides administrative access without a bastion host.
- NACLs provide subnet-level defense in depth.

## High Availability and Scalability

### Application Tier

- Two Availability Zones
- Application Load Balancer
- EC2 Launch Template
- Auto Scaling Group
- Minimum capacity: 2
- Desired capacity: 2
- Maximum capacity: 6
- Health checks through the target group
- Automatic replacement of unhealthy instances

### Scaling Policies

The primary scaling policy is **target tracking** using average EC2 CPU utilization with a target of 50%.

A step-scaling policy is also documented as an advanced response mechanism for exceptional load conditions. It should be configured so that it does not conflict with the primary target-tracking policy. AWS notes that target tracking is sufficient for many workloads and recommends caution when combining it with step scaling because conflicting policies can cause undesirable behavior.

### Database Tier

Amazon RDS for SQL Server is placed in private database subnets spanning two Availability Zones. The solution uses a SQL Server edition that supports the selected Multi-AZ configuration.

RDS Multi-AZ provides a standby database in another Availability Zone and supports automatic failover while retaining the same database endpoint.

## Observability

CloudWatch monitors the main application and infrastructure signals:

- EC2 CPU utilization
- Auto Scaling Group capacity
- ALB request count
- ALB HTTP 4xx/5xx responses
- ALB unhealthy targets
- RDS CPU utilization
- RDS database connections
- RDS free storage

SNS is used for important alarm notifications.

## AWS Services

| Service | Role |
|---|---|
| Route 53 | DNS and domain routing |
| CloudFront | CDN and static-content delivery |
| AWS WAF | Web application protection |
| S3 | React/Vite static frontend |
| VPC | Network isolation |
| Internet Gateway | Public subnet connectivity |
| NAT Gateway | Private application egress |
| ALB | HTTP/HTTPS load balancing |
| EC2 | Application compute |
| Auto Scaling | Elastic application capacity |
| RDS for SQL Server | Managed relational database |
| IAM | Identity and permissions |
| Secrets Manager | Database credential storage |
| Systems Manager | Bastion-free administration |
| CloudWatch | Metrics, alarms, and dashboards |
| SNS | Alarm notifications |

## Repository Structure

```text
.
├── README.md
├── PROJECT-REQUIREMENTS.md
├── ARCHITECTURE/
│   ├── target-architecture.md
│   └── diagrams/
│       ├── README.md
│       └── aws.jfif
├── AWS/
│   ├── edge/
│   │   └── README.md
│   ├── frontend/
│   │   └── README.md
│   ├── networking/
│   │   ├── README.md
│   │   └── vpc-design.md
│   ├── load-balancing/
│   │   └── README.md
│   ├── compute/
│   │   ├── README.md
│   │   └── user-data.sh
│   ├── database/
│   │   └── README.md
│   ├── security/
│   │   └── README.md
│   ├── monitoring/
│   │   └── README.md
│   └── cost/
│       └── README.md
├── DOCUMENTATION/
│   └── architecture-decisions.md
└── CHANGELOG.md
```

## Design Decisions

The architecture decisions are documented in [DOCUMENTATION/architecture-decisions.md](DOCUMENTATION/architecture-decisions.md).

## Project Scope

This repository is intentionally **architecture-first**. The important deliverable is the AWS solution design and its documentation, not a live AWS environment.

The architecture can be implemented later using the documented network layout, security rules, service configuration, scaling policies, monitoring strategy, and operational model.
