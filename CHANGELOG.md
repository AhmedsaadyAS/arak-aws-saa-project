# Changelog

All meaningful project progress is recorded here as the AWS architecture is designed and implemented.

## 2026-08-20

### Current Authoritative Status

- Manual architecture: COMPLETE.
- CloudFormation networking: VALIDATED through `arak-network-test` with `CREATE_COMPLETE`.
- CloudFormation security: template created, not yet validated or deployed.
- Remaining IaC layers: Security -> Database -> Compute -> Load Balancer -> Monitoring.

### Manual Architecture Completed

- Completed and validated the private application compute layer.
- Completed and validated Amazon RDS for SQL Server.
- Created `arak-db-subnet-group` using the private database subnets.
- Validated EC2 -> RDS connectivity on TCP port `1433`.
- Validated Arak Backend -> RDS connectivity through Entity Framework Core.
- Completed Docker-based backend deployment.
- Validated backend container health.
- Validated `/health` endpoint with HTTP `200 OK`.
- Created Target Group `arak-app-tg`.
- Configured HTTP target traffic on port `5000`.
- Configured Target Group health checks using `/health`.
- Created Application Load Balancer `arak-alb`.
- Configured the ALB as internet-facing across the two public subnets.
- Connected ALB -> Target Group -> private application instances.
- Validated the ALB DNS `/health` endpoint successfully.
- Completed manual validation of the core AWS architecture.

### Next

- Continue CloudFormation implementation with the Security Groups layer.

### CloudFormation Networking

- Successfully validated and deployed `cloudformation/network.yaml` in the AWS test environment.
- Test stack: `arak-network-test`.
- Confirmed stack resources in the CloudFormation Resources view with status `CREATE_COMPLETE`.
- Confirmed the VPC, six subnets, route tables, routes, associations, Internet Gateway, NAT Gateway, and Elastic IP were created.
- Captured an AWS Console screenshot as deployment evidence.
- Kept the test stack temporarily as proof of deployment.

### Documentation

- Added the manual deployment journey with troubleshooting decisions and validation results.
- Documented `ARAK-Production-EC2-Role` as the EC2 Instance Profile for Secrets Manager and Systems Manager access.
- Documented the current lab choice of one NAT Gateway, `arak-nat-a`, versus the production-oriented one-per-AZ design.

## 2026-08-18

### AWS Networking — VPC Foundation

- Created the `arak-vpc` VPC using CIDR `10.0.0.0/16`.
- Created two Availability Zone layers in `us-east-1`: `us-east-1a` and `us-east-1b`.
- Created the six planned subnets:
  - `arak-public-a` — `10.0.1.0/24` — `us-east-1a`
  - `arak-public-b` — `10.0.2.0/24` — `us-east-1b`
  - `arak-app-a` — `10.0.11.0/24` — `us-east-1a`
  - `arak-app-b` — `10.0.12.0/24` — `us-east-1b`
  - `arak-db-a` — `10.0.21.0/24` — `us-east-1a`
  - `arak-db-b` — `10.0.22.0/24` — `us-east-1b`
- Created and attached the `arak-igw` Internet Gateway to `arak-vpc`.
- Created the `arak-public-rt` route table.
- Associated `arak-public-a` and `arak-public-b` with `arak-public-rt`.
- Added the public default route `0.0.0.0/0 -> Internet Gateway`.

### Current architecture status

The VPC foundation and public routing are now **deployed in AWS**. The private application routing, NAT Gateway strategy, DB routing, Security Groups, and application/database deployment are still pending.

### Next step

Create and validate the NAT Gateway strategy, then configure private application route tables so the App subnets can reach the Internet through NAT without receiving direct Internet traffic through an Internet Gateway.

## 2026-08-17

### Documentation / Architecture

- Created the public project repository.
- Added the initial project README and requirements documentation.
- Documented the current Arak single-EC2 prototype.
- Added the target architecture documentation.
- Added the proposed VPC and networking design.
- Added the initial architecture decision log.

### Current architecture status

The VPC design was **proposed and documented only** at this stage. AWS networking deployment had not started yet.
