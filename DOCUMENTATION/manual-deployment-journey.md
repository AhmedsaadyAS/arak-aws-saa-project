# Arak Manual AWS Deployment Journey

This document records the actual manual implementation journey of the Arak AWS architecture, including the main deployment steps, problems encountered, root causes, solutions, and validation results.

The purpose is to preserve the implementation reasoning before continuing Infrastructure as Code.

## 1. VPC and Network Foundation

The multi-AZ VPC uses CIDR `10.0.0.0/16` in `us-east-1` across `us-east-1a` and `us-east-1b`.

| Layer | AZ-A | AZ-B |
|---|---|---|
| Public | `10.0.1.0/24` | `10.0.2.0/24` |
| Application | `10.0.11.0/24` | `10.0.12.0/24` |
| Database | `10.0.21.0/24` | `10.0.22.0/24` |

Public subnets serve the Internet-facing ALB. Application instances run in private application subnets. RDS uses private database subnets.

## 2. Routing and NAT

Implemented network resources include:

- Internet Gateway
- Public route table
- NAT Gateway
- Private application route table
- Private database route table

The current lab uses one NAT Gateway, `arak-nat-a`, for both private application subnets. Database subnets have no direct Internet access.

## 3. Security Groups

- `arak-alb-sg`: controls traffic entering the public ALB.
- `arak-app-sg`: allows application traffic on port `5000` from the ALB.
- `arak-db-sg`: allows SQL Server traffic on port `1433` from the application layer.

Traffic flow:

```text
Internet -> ALB -> Application EC2 -> RDS
```

Application and database ports are not intended to be directly accessible from the public Internet.

## 4. IAM Role

EC2 instances use `ARAK-Production-EC2-Role` through an Instance Profile. It provides AWS service access required by the instances, including Secrets Manager and Systems Manager, without storing long-lived access keys on the servers.

## 5. RDS Deployment

- Identifier: `arak-db-2`
- Engine: SQL Server Express Edition
- Port: `1433`
- Publicly accessible: No
- DB subnet group: `arak-db-subnet-group`
- Subnets: `arak-db-a`, `arak-db-b`

## 6. RDS Subnet Group Problem

The existing DB subnet group initially contained subnets that were not intended to remain part of the database design. AWS returned `Some of the subnets to be deleted are currently in use` when a subnet was removed while still associated with the DB instance.

A dedicated DB subnet group was created using only `arak-db-a` and `arak-db-b`, and the RDS instance was moved to it.

## 7. RDS Connectivity Validation

The initial `nc -vz <RDS-ENDPOINT> 1433` test could not run because `nc` was not installed. TCP connectivity was tested with Bash `/dev/tcp` instead and returned `RDS CONNECTION OK`, confirming EC2-to-RDS connectivity on port `1433`.

## 8. Secrets Manager Problem

The EC2 instance initially received `AccessDeniedException` for Secrets Manager operations while using `ARAK-Production-EC2-Role`. The required access was corrected for the role, after which the secret could be retrieved at runtime without hardcoding the database password.

## 9. EC2 and Docker

The backend image is `asdy74/arak-backend:v1`. The container is `arak-api` on port `5000`. The application uses credentials retrieved from Secrets Manager to connect to RDS.

## 10. Launch Template and Auto Scaling

Launch Template `arak-app-template` uses `ARAK-Production-EC2-Role` and the sanitized User Data in [../AWS/compute/user-data.sh](../AWS/compute/user-data.sh). The bootstrap installs Docker, retrieves database credentials, pulls the backend image, and starts the container.

## 11. Instance Refresh

After the Launch Template was updated, an Auto Scaling Instance Refresh replaced the existing instance. Replacement instances started successfully with Docker and the backend container running.

## 12. Backend Health Validation

The local endpoint `http://localhost:5000/health` returned HTTP `200 OK` with:

```json
{"status":"healthy"}
```

The container also reported `healthy`.

## 13. Application Load Balancer

- Load Balancer: `arak-alb`
- Scheme: Internet-facing
- IP type: IPv4
- Public subnets: `arak-public-a`, `arak-public-b`
- Target Group: `arak-app-tg`
- Target type: Instance
- Protocol: HTTP
- Port: `5000`
- Health check: `/health`

## 14. ALB Browser Testing Problem

Opening the ALB root path `/` returned `404`. The ALB was working, but the ASP.NET Core application does not expose a required root route. The correct validation URL is the known application endpoint `/health`, which returned `{"status":"healthy"}` with HTTP `200`.

The root `404` is therefore not an ALB failure.

## 15. CloudFormation Network Test

After manual validation, `cloudformation/network.yaml` was deployed as `arak-network-test` in `us-east-1`. It created the VPC, public and private subnets, Internet Gateway, NAT Gateway, Elastic IP, route tables, routes, and subnet associations.

The stack reached `CREATE_COMPLETE`, and the AWS Console Resources view was captured as evidence.

## 16. Current Status

Manual architecture: **COMPLETE**

CloudFormation networking: **VALIDATED**

Remaining IaC layers:

```text
Security -> Database -> Compute -> Load Balancer -> Monitoring
```

## Lessons

- RDS subnet groups must be changed with awareness of resources currently using their subnets.
- Security Groups should represent ALB, application, and database layers.
- IAM roles are preferable to long-lived access keys on EC2.
- Private EC2 instances do not need public Internet exposure when the ALB is the public entry point.
- A known valid endpoint such as `/health` is the right application-level ALB test.
- Auto Scaling requires reproducible initialization through Launch Template User Data.
