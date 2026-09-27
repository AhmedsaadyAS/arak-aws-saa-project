# Practical AWS Implementation

## Purpose

The repository contains the complete solution architecture for the Arak SAA project. This document records the AWS components that were actually deployed and validated during the practical implementation.

## Network Foundation

The practical environment used:

- VPC: `arak-vpc` — `10.0.0.0/16`
- Region: `us-east-1`
- Availability Zones: `us-east-1a`, `us-east-1b`
- Public subnets:
  - `arak-public-a` — `10.0.1.0/24`
  - `arak-public-b` — `10.0.2.0/24`
- Private application subnets:
  - `arak-app-a` — `10.0.11.0/24`
  - `arak-app-b` — `10.0.12.0/24`
- Private database subnets:
  - `arak-db-a` — `10.0.21.0/24`
  - `arak-db-b` — `10.0.22.0/24`
- Internet Gateway: `arak-igw`
- NAT Gateway: `arak-nat-a`
- Route tables: `arak-public-rt`, `arak-private-app-rt`, `arak-private-db-rt`

## Security

The deployed security model used separate security groups:

- `arak-alb-sg`
- `arak-app-sg`
- `arak-db-sg`

Application traffic was separated from database traffic, with the application layer using port `5000` and SQL Server using port `1433`.

## Compute and Application

The practical deployment used:

- Launch Template: `arak-app-template`
- Auto Scaling Group: `arak-app-asg`
- Private EC2 instances using Amazon Linux 2023
- Docker image: `asdy74/arak-backend:v1`
- Container: `arak-api`
- Application port: `5000`
- Health endpoint: `/health`

The backend returned HTTP `200 OK` with the expected healthy response.

## Database

The practical database was:

- RDS identifier: `arak-db-2`
- Engine: SQL Server Express Edition
- Port: `1433`
- Public accessibility: disabled
- DB subnet group: `arak-db-subnet-group`

EC2-to-RDS TCP connectivity was validated on port `1433`.

## Load Balancing

The practical load-balancing layer used:

- ALB: `arak-alb`
- Scheme: Internet-facing
- Public subnets: `arak-public-a`, `arak-public-b`
- Target Group: `arak-app-tg`
- Target type: Instance
- Protocol: HTTP
- Port: `5000`
- Health check path: `/health`

The ALB health endpoint returned the application healthy response with HTTP `200`.

## IAM and Operations

EC2 instances used the IAM role `ARAK-Production-EC2-Role` with an Instance Profile. Systems Manager access was used for instance administration, and database credentials were retrieved through Secrets Manager rather than stored as long-lived credentials on the server.

## Infrastructure as Code Validation

The network CloudFormation template is preserved under `cloudformation/network.yaml`. It was deployed as `arak-network-test` in `us-east-1` and reached `CREATE_COMPLETE`.

## Evidence

Screenshots supporting the practical implementation are available under [EVIDENCE/screenshots](../EVIDENCE/screenshots/README.md).

The practical implementation is documented separately from the full solution architecture so that the repository shows both the designed AWS solution and the concrete AWS work performed on the project.
