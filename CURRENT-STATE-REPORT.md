# Arak AWS SAA Project - Current Status Report

**Repository:** `AhmedsaadyAS/arak-aws-saa-project`  
**Branch:** `main`  
**Report date:** 2026-08-20

## Executive Summary

This repository is a documentation-first AWS Solutions Architect Associate project for the Arak education-management SaaS application. The selected Manara scope is Project 1: **Scalable Web Application with ALB and Auto Scaling**.

The original single-host prototype has been migrated into a manually implemented and validated AWS architecture with public load balancing, private application compute, private RDS SQL Server, Secrets Manager, Systems Manager, and end-to-end application connectivity.

The manual AWS architecture is complete. CloudFormation networking has also been validated through the `arak-network-test` stack. The remaining CloudFormation layers are not yet implemented or validated.

## Final Validated Architecture

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Target Group
   |
   v
Private EC2 Auto Scaling Group across two AZs
   |
   v
Dockerized Arak ASP.NET Core API
   |
   v
Private Amazon RDS for SQL Server
```

The application instances do not require public IP addresses. The ALB is deployed in public subnets, application instances are in private subnets, and the database is private.

## Network Design

| Layer | AZ-1 | AZ-2 | Purpose |
|---|---|---|---|
| Public | `10.0.1.0/24` | `10.0.2.0/24` | ALB and NAT Gateway |
| Private application | `10.0.11.0/24` | `10.0.12.0/24` | EC2 Auto Scaling instances |
| Private database | `10.0.21.0/24` | `10.0.22.0/24` | RDS subnet group |

**VPC CIDR:** `10.0.0.0/16`  
**Region:** `us-east-1`  
**Availability Zones:** `us-east-1a`, `us-east-1b`

Database subnets have no Internet default route. Private application egress uses NAT Gateway `arak-nat-a`.

## Security and Operations

- `arak-alb-sg` controls traffic entering the ALB.
- `arak-app-sg` allows application traffic from the ALB.
- `arak-db-sg` allows SQL Server traffic from the application layer.
- Systems Manager Session Manager provides private EC2 administration.
- IAM role: `ARAK-Production-EC2-Role`.
- RDS credentials are managed through AWS Secrets Manager.
- No credentials or secret values are stored in Git.

## Validated Components

### Networking

- VPC `arak-vpc`
- Six subnets across two Availability Zones
- Internet Gateway `arak-igw`
- Public route table `arak-public-rt`
- NAT Gateway `arak-nat-a`
- Private application route table `arak-private-app-rt`
- Private database route table `arak-private-db-rt`

### Compute and application

- Launch Template `arak-app-template`
- Auto Scaling Group `arak-app-asg`
- Amazon Linux 2023, `t3.micro`
- Desired capacity 1, minimum 1, maximum 2
- Docker image `asdy74/arak-backend:v1`
- Container `arak-api`, port `5000`
- `GET /health` returns HTTP 200 and healthy status
- Auto Scaling Instance Refresh completed successfully

### Database

- RDS identifier: `arak-db-2`
- Engine: SQL Server Express Edition
- Instance class: `db.t3.micro`
- Port: `1433`
- Publicly accessible: No
- DB subnet group: `arak-db-subnet-group`
- EC2-to-RDS and backend-to-RDS connectivity validated

### Load balancing

- Application Load Balancer in public subnets
- Target Group connected to the private ASG
- HTTP health check on port `5000`, path `/health`
- ALB -> Target Group -> ASG flow validated end to end

## Next Phase: CloudFormation

Manual implementation is complete. The networking template has been validated. The remaining work is:

```text
Network -> Security -> Database -> Compute -> Load Balancer -> Monitoring
```

Planned IaC files:

- `network.yaml`
- `security.yaml`
- `database.yaml`
- `compute.yaml`
- `load-balancer.yaml`
- `monitoring.yaml`
- `main.yaml`

Each template must be reviewed, deployed, validated, and supported by evidence before it is considered complete.

## IAM

- IAM role: `ARAK-Production-EC2-Role`.
- Attached to application EC2 instances through an Instance Profile.
- Used for AWS service access from EC2.
- Used for Secrets Manager access.
- Used for Systems Manager administration.
- No long-lived AWS access keys are stored on the instances.

## Remaining Work

- CloudFormation templates and full-stack deployment validation
- CloudWatch dashboard, alarms, and SNS notifications
- Final architecture diagram
- AWS resource IDs and screenshots/evidence
- Synchronization of final submission documentation
- Optional Route 53, CloudFront, and WAF if required by scope
