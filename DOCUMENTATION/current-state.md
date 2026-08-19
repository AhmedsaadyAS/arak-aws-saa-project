# Current State

## Manual AWS Architecture

The Arak AWS application has been migrated from the original single-EC2 prototype to a manually validated multi-tier AWS architecture.

### Network

- VPC: `arak-vpc`
- CIDR: `10.0.0.0/16`
- Two Availability Zones:
  - `us-east-1a`
  - `us-east-1b`
- Public, private application, and private database subnets are configured.
- Internet Gateway configured.
- NAT Gateway configured.
- Private application routing configured.
- Private database routing configured without an Internet default route.

The current lab uses one NAT Gateway, `arak-nat-a`, for private application subnet outbound traffic. One NAT Gateway per AZ remains the production-oriented design target.

### Compute

- Application instances run in private subnets.
- Auto Scaling Group: `arak-app-asg`.
- Launch Template: `arak-app-template`.
- Instance type: `t3.micro`.
- Desired capacity: 1.
- Minimum capacity: 1.
- Maximum capacity: 2.
- Systems Manager Session Manager is available for administration.

### Application

- Docker-based deployment is used for the Arak Backend.
- Image: `asdy74/arak-backend:v1`.
- Container: `arak-api`.
- Application port: `5000`.
- `/health` returns HTTP `200 OK`.
- Container health status has been validated.

### Database

- RDS SQL Server instance: `arak-db-2`.
- DB subnet group: `arak-db-subnet-group`.
- RDS is private.
- Port: `1433`.
- EC2 -> RDS connectivity validated.
- Backend -> RDS connectivity validated.
- Credentials are managed through Secrets Manager.

### Load Balancing

- Application Load Balancer: `arak-alb`.
- Internet-facing.
- Public subnets:
  - `arak-public-a`
  - `arak-public-b`
- Target Group: `arak-app-tg`.
- Backend targets use port `5000`.
- Health check path: `/health`.
- ALB DNS `/health` endpoint successfully returned HTTP `200 OK`.

### IAM

- IAM role: `ARAK-Production-EC2-Role`.
- Attached to application EC2 instances through an Instance Profile.
- Used for AWS service access from EC2.
- Used for Secrets Manager access.
- Used for Systems Manager administration.
- No long-lived AWS access keys are stored on the instances.

## Current Validation

The current application request path has been validated end-to-end:

```text
Internet
-> ALB
-> Target Group
-> Private EC2
-> Docker
-> Arak Backend
-> RDS
```

## Current Phase

The manual AWS architecture is complete.

The project is now entering the Infrastructure as Code phase.

CloudFormation networking has been validated through test stack `arak-network-test` with status `CREATE_COMPLETE`. The remaining IaC layers will be implemented incrementally based on the manually validated architecture.
