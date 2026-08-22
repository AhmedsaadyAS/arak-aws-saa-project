# ARAK AWS Architecture Diagrams

This directory contains the final visual representation of the validated ARAK AWS Solution Architecture.

## Final Architecture Diagram

![ARAK AWS Solution Architecture](./aws.jfif)

The original project architecture image is used as the source-of-truth visual diagram. It presents the target architecture and implementation details relevant to the project, including the VPC, Availability Zones, subnet CIDRs, NAT Gateway, Application Load Balancer, Target Group, Auto Scaling Group, Dockerized ASP.NET Core application, private RDS for SQL Server, security and management services, and monitoring.

## Network Layout

### VPC

- VPC: `arak-vpc`
- CIDR: `10.0.0.0/16`
- Region: `us-east-1`

### Availability Zone 1 — `us-east-1a`

| Tier | Resource | CIDR |
|---|---|---|
| Public | `arak-public-1a` | `10.0.1.0/24` |
| Private Application | `arak-private-app-1a` | `10.0.11.0/24` |
| Private Database | `arak-private-db-1a` | `10.0.21.0/24` |

### Availability Zone 2 — `us-east-1b`

| Tier | Resource | CIDR |
|---|---|---|
| Public | `arak-public-1b` | `10.0.2.0/24` |
| Private Application | `arak-private-app-1b` | `10.0.12.0/24` |
| Private Database | `arak-private-db-1b` | `10.0.22.0/24` |

## Application Path

The primary request path shown in the diagram is:

`Users / Internet → Route 53 → CloudFront → AWS WAF → Application Load Balancer → Target Group → EC2 Auto Scaling Group → ASP.NET Core API → Amazon RDS for SQL Server`

## Application Layer

- Auto Scaling Group: `arak-app-asg`
- Minimum capacity: `1`
- Desired capacity: `1`
- Maximum capacity: `2`
- Application: Dockerized ASP.NET Core API
- Application port: `5000`
- Health check: `GET /health`
- Expected health response: HTTP `200`

## Database Layer

- Service: Amazon RDS for SQL Server
- Identifier: `arak-db-2`
- Instance class: `db.t3.micro`
- Port: `1433`
- Access: Private
- Deployment: Multi-AZ
- Database subnet group spans both private database subnets

## Security, Management, and Monitoring

### Security & Management

- AWS IAM
- `ARAK-Production-EC2-Role`
- AWS Systems Manager Session Manager
- AWS Secrets Manager

### Monitoring

- Amazon CloudWatch
- Amazon SNS

## Supporting Networking

- Internet Gateway for public subnet connectivity
- `arak-nat-a` NAT Gateway for private application subnet outbound access
- Private database subnets do not require a direct Internet default route

## Source of Truth

The `aws.jfif` image in this directory is the original project architecture diagram and is the visual source of truth. The accompanying documentation explains the architecture elements and implementation details.
