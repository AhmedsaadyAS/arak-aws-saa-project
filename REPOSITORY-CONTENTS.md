# Arak AWS SAA Project - Repository Contents

Generated copy bundle of all current text files. Binary evidence images are listed separately at the end.

================================================================================
FILE: ARCHITECTURE/diagrams/README.md
================================================================================

# Architecture Diagrams

Store solution architecture diagrams and exported diagram assets here.

================================================================================
FILE: ARCHITECTURE/target-architecture.md
================================================================================

# Target Architecture

## Objective

Transform the existing Arak single-EC2 prototype into a scalable, highly available AWS architecture that matches the selected Manara Project 1 scope: **Scalable Web Application with ALB and Auto Scaling**.

## Target Request Flow

Internet users will access Arak through an edge and load-balancing layer before reaching application instances in private subnets.

Validated flow:

1. Route 53 (optional, when a domain is available)
2. CloudFront + WAF (where justified)
3. Application Load Balancer in public subnets
4. EC2 Auto Scaling Group across two Availability Zones in private subnets
5. Managed SQL Server database in private database subnets

The core flow through the ALB, Target Group, private Auto Scaling instances, Docker backend, and private RDS SQL Server has been manually validated. Route 53, CloudFront, and WAF remain optional services for the final scope.

## Network Design

The final VPC will span two Availability Zones and separate public, private application, and private database subnets.

### Public Layer

- ALB subnets in AZ1 and AZ2
- Internet Gateway attached to the VPC
- Public route table for internet-facing resources

### Private Application Layer

- EC2 instances managed by the Auto Scaling Group
- No direct inbound access from the internet
- Outbound internet access controlled through NAT where required

### Private Database Layer

- RDS for SQL Server
- Database subnet group spanning AZ1 and AZ2
- No public database access

## Application Layer

The application instances will run the Arak deployment package consistently through a Launch Template.

The initial implementation strategy is to preserve the existing application deployment model (Nginx + React production build + ASP.NET Core API) while making the compute layer replaceable and horizontally scalable.

## Database Layer

The current local SQL Server instance on the prototype EC2 has been replaced for the validated architecture by Amazon RDS for SQL Server.

The production application uses the RDS endpoint instead of a database process running on the EC2 host.

## Availability and Scalability

- ALB distributes traffic across healthy application instances.
- Auto Scaling Group maintains the desired instance capacity.
- Instances are distributed across two Availability Zones.
- Health checks allow unhealthy instances to be replaced.
- RDS Multi-AZ provides database failover capability.

## Security Controls

Validated controls include:

- Security Groups with least-necessary traffic paths
- NACLs for subnet-level controls where useful
- IAM roles instead of hardcoded AWS credentials
- Systems Manager Session Manager for administrative access
- Private application and database subnets
- WAF where the final edge design uses CloudFront/ALB protection

## Observability

Planned operational services not yet completed:

- CloudWatch metrics and logs
- CloudWatch alarms
- SNS notifications for important alarms

## Important Design Rule

The manual AWS architecture is complete and verified. The next implementation milestone is reproducing it with CloudFormation.

## Implementation Status

### Manually validated

- Networking
- Security Groups
- RDS
- EC2 Auto Scaling
- Docker deployment
- Application Load Balancer
- Target Group
- End-to-end health check

### Infrastructure as Code

CloudFormation implementation has started.

The networking template was successfully deployed as `arak-network-test` in `us-east-1` with status `CREATE_COMPLETE`.

================================================================================
FILE: AWS/compute/README.md
================================================================================

# Compute

Document EC2 Launch Templates, Auto Scaling Groups, instance refreshes, and Systems Manager configuration here.

## Launch Template

- Launch Template: `arak-app-template`
- AMI: Amazon Linux 2023
- Instance type: `t3.micro`
- IAM instance profile: `ARAK-Production-EC2-Role`
- Application Security Group: `arak-app-sg`
- Application subnets: `arak-app-a` and `arak-app-b`
- Auto Scaling Group: `arak-app-asg`
- Desired capacity: 1
- Minimum capacity: 1
- Maximum capacity: 2

The Launch Template uses User Data to bootstrap the application instance. The sanitized reference implementation is [user-data.sh](user-data.sh).

## IAM Instance Profile

Instance profile: `ARAK-Production-EC2-Role`

The Launch Template associates the EC2 instances with this IAM instance profile. The role provides the AWS permissions required by the application instances, including access to Secrets Manager and Systems Manager.

## Why User Data Is Used

The Launch Template uses User Data so that every new EC2 instance can bootstrap itself automatically. This is important for Auto Scaling because replacement instances must deploy the application without manual configuration.

## EC2 User Data

The bootstrap process:

1. Installs Docker and `jq`.
2. Starts Docker and enables it at boot.
3. Pulls the Arak backend image: `asdy74/arak-backend:v1`.
4. Retrieves the RDS credentials from AWS Secrets Manager.
5. Extracts `username` and `password` from the secret JSON.
6. Builds the SQL Server connection string using the RDS endpoint.
7. Starts the `arak-api` Docker container.
8. Exposes the backend on port `5000`.
9. Runs the application in `Production` mode.

The EC2 instance uses the `ARAK-Production-EC2-Role` IAM instance profile to access Secrets Manager. Credentials are retrieved at runtime and are not written into User Data or committed to Git.

The reference User Data intentionally contains these placeholders:

```text
SECRET_ARN="<RDS_SECRET_ARN>"
RDS_HOST="<RDS_ENDPOINT>"
```

Production values must be supplied through the deployment process or a managed template parameter mechanism. Do not replace the placeholders with secret values in this repository.

## Application Validation

- Docker container: `arak-api`
- Backend image: `asdy74/arak-backend:v1`
- Application port: `5000`
- Health endpoint: `/health`
- Expected response: `{ "status": "healthy" }`
- Validated response status: HTTP `200 OK`

The User Data configuration was used by the Launch Template to bootstrap replacement instances during the successful Auto Scaling Instance Refresh.

## Bootstrap Process

1. Install Docker and `jq`.
2. Start Docker.
3. Pull the Arak backend image.
4. Retrieve database credentials from Secrets Manager.
5. Build the SQL Server connection string.
6. Start the `arak-api` container.
7. Expose port `5000`.
8. Run the application in Production mode.

================================================================================
FILE: AWS/compute/user-data.sh
================================================================================

#!/bin/bash
set -euxo pipefail

dnf install -y docker jq

systemctl enable --now docker

until systemctl is-active --quiet docker; do
    sleep 2
done

docker pull asdy74/arak-backend:v1

SECRET_ARN="<RDS_SECRET_ARN>"
RDS_HOST="<RDS_ENDPOINT>"

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --query SecretString \
    --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

docker rm -f arak-api 2>/dev/null || true

docker run -d \
    --name arak-api \
    --restart unless-stopped \
    -p 5000:5000 \
    -e "ConnectionStrings__DefaultConnection=Server=${RDS_HOST},1433;Database=ArakDB;User Id=${DB_USER};Password=${DB_PASSWORD};TrustServerCertificate=True" \
    -e "Jwt__Issuer=ArakAPI" \
    -e "Jwt__Audience=ArakDashboard" \
    -e "Jwt__ExpirationHours=24" \
    -e "ASPNETCORE_ENVIRONMENT=Production" \
    asdy74/arak-backend:v1

================================================================================
FILE: AWS/database/README.md
================================================================================

# Database

## Amazon RDS for SQL Server

The Arak application uses Amazon RDS for SQL Server as the managed database layer.

### Configuration

- Identifier: `arak-db-2`
- Engine: SQL Server Express Edition
- Instance class: `db.t3.micro`
- Port: `1433`
- Public accessibility: Disabled
- DB subnet group: `arak-db-subnet-group`
- Subnets: `arak-db-a`, `arak-db-b`

## Security

Database access is controlled through `arak-db-sg`. TCP `1433` is allowed only from `arak-app-sg`. The database does not allow public inbound access.

## Credentials

Database credentials are stored in AWS Secrets Manager. The EC2 instance retrieves them at runtime using its IAM instance role instead of storing them in the application image or repository.

## Validation

EC2-to-RDS connectivity and backend-to-RDS connectivity through Entity Framework Core were validated successfully.

================================================================================
FILE: AWS/monitoring/README.md
================================================================================

# Monitoring

Document CloudWatch dashboards, alarms, SNS notifications, and operational validation here.

================================================================================
FILE: AWS/networking/README.md
================================================================================

# Networking

## Manual Architecture

The network foundation was manually implemented and validated in `us-east-1`.

- VPC: `arak-vpc`, CIDR `10.0.0.0/16`
- Availability Zones: `us-east-1a`, `us-east-1b`
- Public subnets: `arak-public-a`, `arak-public-b`
- Private application subnets: `arak-app-a`, `arak-app-b`
- Private database subnets: `arak-db-a`, `arak-db-b`
- Internet Gateway: `arak-igw`
- Public route table: `arak-public-rt`
- Private application route table: `arak-private-app-rt`
- Private database route table: `arak-private-db-rt`

## NAT Gateway Implementation

The production-oriented design prefers one NAT Gateway per Availability Zone.

For the current lab implementation, a single NAT Gateway named `arak-nat-a` was deployed in Public-A. Both private application subnets use the private application route table that routes outbound traffic through this NAT Gateway.

This is a cost-optimized lab configuration and introduces a potential cross-AZ dependency for private-subnet egress.

## CloudFormation Validation

The `cloudformation/network.yaml` template was deployed as stack `arak-network-test` in `us-east-1` and reached `CREATE_COMPLETE`. The stack created the VPC, six subnets, gateways, route tables, routes, and subnet associations.

================================================================================
FILE: AWS/networking/vpc-deployment-checklist.md
================================================================================

# VPC Deployment Checklist

## Status

**Complete â€” networking foundation manually implemented and validated.**

This checklist turns the approved VPC design into AWS resources. The deployment is being completed in small validated steps, with evidence added to `EVIDENCE/screenshots/` and the documentation updated after each successful stage.

## Phase 1 â€” Region and Availability Zones

- [x] Confirm AWS region â€” `us-east-1`
- [x] Confirm two Availability Zones available in the selected region
- [x] Record the selected AZ IDs/names in deployment notes â€” `us-east-1a`, `us-east-1b`

## Phase 2 â€” VPC Foundation

- [x] Create VPC: `10.0.0.0/16`
- [x] Enable DNS resolution
- [x] Enable DNS hostnames
- [x] Create and attach Internet Gateway â€” `arak-igw`
- [ ] Record VPC ID and IGW ID in deployment notes

## Phase 3 â€” Subnets

- [x] Public-A: `10.0.1.0/24` â€” `arak-public-a` â€” `us-east-1a`
- [x] Public-B: `10.0.2.0/24` â€” `arak-public-b` â€” `us-east-1b`
- [x] App-A: `10.0.11.0/24` â€” `arak-app-a` â€” `us-east-1a`
- [x] App-B: `10.0.12.0/24` â€” `arak-app-b` â€” `us-east-1b`
- [x] DB-A: `10.0.21.0/24` â€” `arak-db-a` â€” `us-east-1a`
- [x] DB-B: `10.0.22.0/24` â€” `arak-db-b` â€” `us-east-1b`

## Phase 4 â€” Routing

- [x] Public route table with `0.0.0.0/0 -> IGW` â€” `arak-public-rt`
- [x] Associate Public-A and Public-B
- [x] Create NAT Gateway(s) in public subnet(s) â€” `arak-nat-a`
- [x] App-A route: `0.0.0.0/0 -> NAT Gateway`
- [x] App-B route: `0.0.0.0/0 -> NAT Gateway`
- [x] Associate App-A and App-B with private route tables
- [x] Create DB route table(s) with no Internet default route
- [x] Associate DB-A and DB-B

## Phase 5 â€” Security Groups

- [x] ALB Security Group â€” `arak-alb-sg`
- [x] Application Security Group â€” `arak-app-sg`
- [x] Database Security Group â€” `arak-db-sg`
- [x] Verify database TCP 1433 is allowed only from the Application Security Group
- [x] Verify application traffic is allowed only from the ALB Security Group

## Phase 6 â€” NACLs

- [x] Review default NACL behavior
- [x] Add custom NACL rules only when justified by the design
- [x] Document any custom rules

## Validation

- [x] Verify subnet route associations
- [x] Verify private subnets have no direct IGW route
- [x] Verify DB subnets have no Internet default route
- [x] Verify NAT Gateway state is Available
- [ ] Capture evidence screenshots
- [ ] Update deployment notes with resource IDs
- [ ] Mark this checklist complete only after validation

## Cost / HA Note

The target design prefers one NAT Gateway per AZ for AZ independence. If the lab budget requires a single NAT Gateway, document it explicitly as a temporary cost optimization and note the resulting single point of failure for private-subnet Internet egress.

================================================================================
FILE: AWS/networking/vpc-design.md
================================================================================

# VPC and Networking Design

## Status

**Implemented and manually validated.**

This document records the validated network foundation for the Arak AWS Solutions Architect â€“ Associate project. It follows the selected Manara brief: a production-grade EC2 application in a VPC with public and private subnets across two Availability Zones, with ALB, Auto Scaling, NAT Gateway, Security Groups, NACLs, and a private managed database.

## 1. Design Goals

- Use two Availability Zones for high availability.
- Keep the Application Load Balancer in public subnets.
- Keep application EC2 instances in private subnets.
- Keep the database in dedicated private database subnets.
- Avoid direct Internet access to application EC2 instances.
- Provide controlled outbound Internet access from private application subnets through NAT Gateway(s).
- Keep database subnets without a direct Internet route.
- Make the subnet and routing design explicit before creating AWS resources.

## 2. Proposed VPC CIDR

**VPC:** `10.0.0.0/16`

This provides enough address space for the project while leaving room for future subnets without changing the VPC CIDR.

## 3. Proposed Subnet Layout

| Availability Zone | Subnet | CIDR | Type | Intended resources |
|---|---|---|---|---|
| AZ-1 | Public-A | `10.0.1.0/24` | Public | ALB nodes, NAT Gateway |
| AZ-1 | App-A | `10.0.11.0/24` | Private | EC2 Auto Scaling Group |
| AZ-1 | DB-A | `10.0.21.0/24` | Private | RDS subnet group |
| AZ-2 | Public-B | `10.0.2.0/24` | Public | ALB nodes, NAT Gateway |
| AZ-2 | App-B | `10.0.12.0/24` | Private | EC2 Auto Scaling Group |
| AZ-2 | DB-B | `10.0.22.0/24` | Private | RDS subnet group |

The exact AWS Availability Zone names will be selected in the deployment region when the resources are created; the design intentionally refers to AZ-1 and AZ-2 rather than hard-coding names at this stage.

## 4. Internet Gateway

One Internet Gateway will be attached to the VPC.

The public route table will contain:

```text
0.0.0.0/0 -> Internet Gateway
```

This allows resources that are intentionally placed in public subnets to reach the Internet when their security controls also permit the traffic.

## 5. Public Route Table

The public route table will be associated with:

- Public-A
- Public-B

Route:

```text
VPC local route
0.0.0.0/0 -> Internet Gateway
```

The ALB requires public subnets so that it can receive Internet-facing traffic.

## 6. Private Application Route Tables

The application subnets will not have a direct route to the Internet Gateway.

For the production/high-availability target, each AZ will have a NAT Gateway in its corresponding public subnet:

```text
App-A route table:
0.0.0.0/0 -> NAT Gateway in Public-A

App-B route table:
0.0.0.0/0 -> NAT Gateway in Public-B
```

This keeps private EC2 instances private while allowing controlled outbound access for package updates, dependency retrieval, monitoring agents, or other required external connections.

### Cost note

Two NAT Gateways provide better AZ independence but cost more. A single NAT Gateway is acceptable as a temporary cost-saving lab configuration, but it would introduce a cross-AZ dependency and a single point of failure for private-subnet egress. The final production-oriented design therefore uses one NAT Gateway per AZ unless the project budget requires the lab alternative.

## NAT Gateway Implementation

The production-oriented design prefers one NAT Gateway per Availability Zone.

For the current lab implementation, a single NAT Gateway named `arak-nat-a` was deployed in Public-A. Both private application subnets currently use the private application route table that routes outbound traffic through this NAT Gateway.

This is a cost-optimized lab configuration and introduces a potential cross-AZ dependency for private-subnet egress.

## 7. Database Route Tables

The DB subnets will use dedicated database route tables.

They will retain the VPC local route but will not have a default route to the Internet Gateway.

The database therefore remains isolated from direct Internet access.

## 8. Traffic Model

### User to application

1. Internet user reaches the public entry point.
2. Internet-facing ALB receives the request in the public subnets.
3. ALB forwards approved application traffic to healthy EC2 instances in the private App-A/App-B subnets.

### Application to database

1. EC2 instances initiate database connections.
2. The database Security Group allows SQL Server traffic only from the application Security Group.
3. RDS remains in the private DB subnets.

### Private outbound traffic

1. EC2 initiates an outbound connection when required.
2. Traffic goes through the AZ-local NAT Gateway.
3. NAT Gateway is located in a public subnet and uses the Internet Gateway for Internet egress.
4. Internet hosts cannot initiate a new inbound connection through the NAT Gateway to the private EC2 instance.

## 9. Security Group Plan

Security Groups will be stateful and resource-specific.

### ALB Security Group

Allow:

- TCP 80 from Internet for the initial HTTP deployment/testing path.
- TCP 443 from Internet when HTTPS is introduced.

Do not allow database access from the ALB Security Group.

### Application Security Group

Allow the application port only from the ALB Security Group.

Do not allow the application port directly from `0.0.0.0/0`.

### Database Security Group

Allow TCP 1433 only from the Application Security Group because Arak currently uses SQL Server.

No public inbound database rule will be created.

## 10. NACL Plan

Network ACLs will provide subnet-level defense in depth.

The first implementation should remain simple and avoid duplicating every Security Group rule. The design will document any custom NACL rules that are actually required.

The primary workload-level access control remains Security Groups because they are attached to the relevant resources and are stateful.

## 11. DNS and Higher-Level Edge Services

Route 53, CloudFront, and WAF are part of the expected target architecture from the project brief, but they are intentionally handled after the core VPC, ALB, Auto Scaling, and database path is working.

This keeps the implementation incremental and makes it easier to validate each layer.

## 12. Implementation Record

1. AWS region: `us-east-1`, Availability Zones: `us-east-1a` and `us-east-1b`.
2. VPC `10.0.0.0/16` and six subnets were created.
3. Internet Gateway, public routing, NAT Gateway, private application routing, and private database routing were created.
4. ALB, application, and database Security Groups were created and validated.
5. EC2-to-RDS connectivity and the complete ALB-to-application flow were validated.
6. The next implementation order is CloudFormation networking, security, database, compute, load balancing, and monitoring.

## 13. Manual Validation Status

The VPC, subnet layout, routing, NAT Gateway, database isolation, Security Groups, and application traffic path are considered complete for the manual architecture phase. Resource IDs and screenshots remain documentation work for the evidence package.

================================================================================
FILE: AWS/security/README.md
================================================================================

# Security

## Security Group Flow

```text
Internet -> arak-alb-sg -> arak-app-sg -> arak-db-sg
```

### `arak-alb-sg`

The public entry point allows TCP `80` from the Internet to the Application Load Balancer.

### `arak-app-sg`

Allows TCP `5000` from `arak-alb-sg` only. The application port is not exposed directly to the Internet.

### `arak-db-sg`

Allows TCP `1433` from `arak-app-sg` only. SQL Server is not exposed publicly.

## IAM

The application EC2 instances use the IAM role `ARAK-Production-EC2-Role`, attached through an IAM Instance Profile.

The role provides AWS permissions required by the application instances without storing AWS access keys on the servers.

### Secrets Manager Access

The EC2 role allows the application instance to retrieve RDS database credentials from AWS Secrets Manager at runtime. Database credentials are not hardcoded in the application image or stored in Git.

### Systems Manager

The EC2 instances use the IAM role required for AWS Systems Manager Session Manager administration. This allows administrative access without a public IP or direct SSH access.

## NACLs

NACLs provide subnet-level defense in depth where justified. Security Groups remain the primary workload-level firewall.

================================================================================
FILE: CHANGELOG.md
================================================================================

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

### AWS Networking â€” VPC Foundation

- Created the `arak-vpc` VPC using CIDR `10.0.0.0/16`.
- Created two Availability Zone layers in `us-east-1`: `us-east-1a` and `us-east-1b`.
- Created the six planned subnets:
  - `arak-public-a` â€” `10.0.1.0/24` â€” `us-east-1a`
  - `arak-public-b` â€” `10.0.2.0/24` â€” `us-east-1b`
  - `arak-app-a` â€” `10.0.11.0/24` â€” `us-east-1a`
  - `arak-app-b` â€” `10.0.12.0/24` â€” `us-east-1b`
  - `arak-db-a` â€” `10.0.21.0/24` â€” `us-east-1a`
  - `arak-db-b` â€” `10.0.22.0/24` â€” `us-east-1b`
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

================================================================================
FILE: cloudformation/network.yaml
================================================================================

AWSTemplateFormatVersion: '2010-09-09'

Description: >
  Arak AWS SAA Project - Network infrastructure.
  Creates the VPC, public subnets, private application subnets,
  private database subnets, Internet Gateway, NAT Gateway,
  route tables, routes, and subnet associations.

Resources:

  # =========================
  # VPC
  # =========================

  ArakVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: arak-vpc


  # =========================
  # Internet Gateway
  # =========================

  ArakInternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: arak-igw

  ArakInternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref ArakVPC
      InternetGatewayId: !Ref ArakInternetGateway


  # =========================
  # Public Subnets
  # =========================

  ArakPublicA:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ArakVPC
      AvailabilityZone: us-east-1a
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: arak-public-a

  ArakPublicB:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ArakVPC
      AvailabilityZone: us-east-1b
      CidrBlock: 10.0.2.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: arak-public-b


  # =========================
  # Private Application Subnets
  # =========================

  ArakAppA:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ArakVPC
      AvailabilityZone: us-east-1a
      CidrBlock: 10.0.11.0/24
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: arak-app-a

  ArakAppB:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ArakVPC
      AvailabilityZone: us-east-1b
      CidrBlock: 10.0.12.0/24
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: arak-app-b


  # =========================
  # Private Database Subnets
  # =========================

  ArakDBA:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ArakVPC
      AvailabilityZone: us-east-1a
      CidrBlock: 10.0.21.0/24
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: arak-db-a

  ArakDBB:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ArakVPC
      AvailabilityZone: us-east-1b
      CidrBlock: 10.0.22.0/24
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: arak-db-b


  # =========================
  # Public Route Table
  # =========================

  ArakPublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref ArakVPC
      Tags:
        - Key: Name
          Value: arak-public-rt

  ArakPublicRoute:
    Type: AWS::EC2::Route
    DependsOn: ArakInternetGatewayAttachment
    Properties:
      RouteTableId: !Ref ArakPublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref ArakInternetGateway

  ArakPublicAAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref ArakPublicA
      RouteTableId: !Ref ArakPublicRouteTable

  ArakPublicBAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref ArakPublicB
      RouteTableId: !Ref ArakPublicRouteTable


  # =========================
  # NAT Gateway
  # =========================

  ArakNatEIP:
    Type: AWS::EC2::EIP
    DependsOn: ArakInternetGatewayAttachment
    Properties:
      Domain: vpc
      Tags:
        - Key: Name
          Value: arak-nat-eip

  ArakNatGateway:
    Type: AWS::EC2::NatGateway
    DependsOn: ArakInternetGatewayAttachment
    Properties:
      AllocationId: !GetAtt ArakNatEIP.AllocationId
      SubnetId: !Ref ArakPublicA
      Tags:
        - Key: Name
          Value: arak-nat-a


  # =========================
  # Private Application Route Table
  # =========================

  ArakPrivateAppRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref ArakVPC
      Tags:
        - Key: Name
          Value: arak-private-app-rt

  ArakPrivateAppRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref ArakPrivateAppRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref ArakNatGateway

  ArakAppAAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref ArakAppA
      RouteTableId: !Ref ArakPrivateAppRouteTable

  ArakAppBAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref ArakAppB
      RouteTableId: !Ref ArakPrivateAppRouteTable


  # =========================
  # Private Database Route Table
  # =========================

  ArakPrivateDBRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref ArakVPC
      Tags:
        - Key: Name
          Value: arak-private-db-rt

  ArakDBAAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref ArakDBA
      RouteTableId: !Ref ArakPrivateDBRouteTable

  ArakDBBAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref ArakDBB
      RouteTableId: !Ref ArakPrivateDBRouteTable


Outputs:

  VPCId:
    Description: Arak VPC ID
    Value: !Ref ArakVPC
    Export:
      Name: Arak-VPC-ID

  PublicSubnetA:
    Description: Public subnet in us-east-1a
    Value: !Ref ArakPublicA
    Export:
      Name: Arak-Public-A

  PublicSubnetB:
    Description: Public subnet in us-east-1b
    Value: !Ref ArakPublicB
    Export:
      Name: Arak-Public-B

  AppSubnetA:
    Description: Private application subnet in us-east-1a
    Value: !Ref ArakAppA
    Export:
      Name: Arak-App-A

  AppSubnetB:
    Description: Private application subnet in us-east-1b
    Value: !Ref ArakAppB
    Export:
      Name: Arak-App-B

  DBSubnetA:
    Description: Private database subnet in us-east-1a
    Value: !Ref ArakDBA
    Export:
      Name: Arak-DB-A

  DBSubnetB:
    Description: Private database subnet in us-east-1b
    Value: !Ref ArakDBB
    Export:
      Name: Arak-DB-B

  NatGatewayId:
    Description: NAT Gateway ID
    Value: !Ref ArakNatGateway

================================================================================
FILE: cloudformation/README.md
================================================================================

# AWS CloudFormation IaC

This directory is the source of truth for recreating the manually validated Arak AWS Solutions Architect Associate architecture.

## Current Phase

CloudFormation is being used to reproduce the manually validated AWS architecture. The manual architecture is complete, while Infrastructure as Code is partially complete.

The IaC objective is to recreate the environment from code, validate each layer, capture evidence, and remove lab resources when they are no longer required.

## Network Template Deployment Evidence

The `network.yaml` template was successfully validated and deployed in the AWS test environment.

- Test stack: `arak-network-test`
- Region: `us-east-1`
- Deployment result: `CREATE_COMPLETE`
- Validation: CloudFormation Resources view confirmed the created VPC, subnets, route tables, routes, subnet associations, Internet Gateway, NAT Gateway, and Elastic IP.
- Evidence: AWS CloudFormation Resources screenshot captured after deployment.

The test stack is intentionally being kept temporarily as proof of deployment. It must not be deleted until the evidence and validation review is complete.

## Validated CloudFormation Resources

### Networking

- Template: `network.yaml`
- Test stack: `arak-network-test`
- Region: `us-east-1`
- Status: `CREATE_COMPLETE`
- Result: networking foundation successfully created and verified in the AWS Console.

## Current IaC Status

| Layer | Template | Status |
|---|---|---|
| Network | `network.yaml` | Validated |
| Security | `security.yaml` | Created, not yet validated |
| Database | `database.yaml` | Not implemented |
| Compute | `compute.yaml` | Not implemented |
| Load Balancer | `load-balancer.yaml` | Not implemented |
| Monitoring | `monitoring.yaml` | Not implemented |

## Current Architecture Progress

### Networking

- VPC and subnet architecture completed.
- Public and private routing completed.
- NAT Gateway configured for private application outbound access.
- Database subnets have no Internet default route.
- Security Groups created for ALB, Application, and Database layers.

### Compute

- Launch Template created: `arak-app-template`.
- AMI: Amazon Linux 2023.
- Instance type: `t3.micro`.
- IAM instance profile: `ARAK-Production-EC2-Role`.
- Security Group: `arak-app-sg`.
- Auto Scaling Group created: `arak-app-asg`.
- Desired capacity: 1.
- Minimum capacity: 1.
- Maximum capacity: 2.
- Application instances are deployed in private App subnets.
- Auto Scaling Instance Refresh completed successfully.

### Application

- Docker installed on application instances.
- Backend image: `asdy74/arak-backend:v1`.
- Container: `arak-api`.
- Application port: `5000`.
- Backend `/health` endpoint validated successfully.
- Container health status validated as healthy.

### Database

- Amazon RDS for SQL Server created.
- DB identifier: `arak-db-2`.
- DB instance class: `db.t3.micro`.
- DB subnet group: `arak-db-subnet-group`.
- Database subnets:
	- `arak-db-a`
	- `arak-db-b`
- RDS is not publicly accessible.
- EC2 -> RDS connectivity validated.
- Backend -> RDS connectivity validated.
- RDS credentials are managed through AWS Secrets Manager.

### Load Balancer

- Application Load Balancer created: `arak-alb`.
- Scheme: Internet-facing.
- IPv4.
- Public subnets:
	- `arak-public-a`
	- `arak-public-b`
- Target Group created: `arak-app-tg`.
- Target type: Instance.
- Protocol: HTTP.
- Target port: `5000`.
- Health check path: `/health`.
- Two application instances registered.
- ALB -> Target Group -> EC2 routing validated.
- ALB DNS `/health` request returned HTTP `200 OK`.

## Current State

The AWS architecture has been manually implemented and validated.

The complete application path is currently:

```text
Internet
-> Application Load Balancer
-> Target Group
-> Private EC2 Auto Scaling Group
-> Docker
-> Arak Backend
-> Private RDS SQL Server
```

CloudFormation is intentionally being implemented after manual validation of the corresponding AWS components.

## Next Phase

The remaining CloudFormation implementation will be created incrementally:

1. Validate `security.yaml`.
2. Create and validate `database.yaml`.
3. Create and validate `compute.yaml`.
4. Create and validate `load-balancer.yaml`.
5. Create and validate `monitoring.yaml`.
6. Create the final `main.yaml` orchestration entry point if needed.

Each template will be validated before moving to the next layer.

## Planned Templates

- `network.yaml` - VPC, subnets, route tables, gateways, and networking resources.
- `security.yaml` - Security Groups and related security resources.
- `database.yaml` - RDS, DB subnet group, and database networking configuration.
- `compute.yaml` - IAM role, Launch Template, Auto Scaling Group, and instance configuration.
- `load-balancer.yaml` - ALB, Target Group, listeners, and health checks.
- `monitoring.yaml` - CloudWatch dashboards, alarms, and SNS notifications.
- `main.yaml` - Final orchestration entry point for modular or nested stacks.

## Implementation Workflow

1. Review the validated networking deployment.
2. Validate the Security Groups template without claiming existing manual groups are managed by it.
4. Translate and validate RDS and database networking.
5. Translate and validate the IAM role, Launch Template, and Auto Scaling Group.
6. Translate and validate the ALB, Target Group, listeners, and health checks.
7. Add monitoring and alerting resources.
8. Add the final orchestration stack where useful.
9. Deploy the complete architecture from CloudFormation.
10. Validate the recreated environment end to end.
11. Capture deployment and validation evidence.
12. Delete the CloudFormation stack after the demonstration when resources are no longer required.

## Status Rule

A CloudFormation resource is complete only after its template has been reviewed, deployed, and validated. Manual AWS completion does not by itself mark the corresponding IaC template complete.

## Immediate Next Step

Proceed to the Security Groups template after the successful `network.yaml` deployment, then continue upward through:

```text
Network -> Security -> Database -> Compute -> Load Balancer -> Monitoring
```

================================================================================
FILE: cloudformation/security.yaml
================================================================================

AWSTemplateFormatVersion: '2010-09-09'

Description: >
  Arak AWS SAA Project - Security Groups.
  Creates the ALB, application, and database security groups
  with layered traffic restrictions.

Parameters:

  VpcId:
    Type: AWS::EC2::VPC::Id
    Description: VPC where the Arak security groups will be created.

Resources:

  # =========================
  # ALB Security Group
  # =========================

  ArakALBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: arak-alb-sg
      GroupDescription: Allow HTTP traffic from the Internet to the ALB.
      VpcId: !Ref VpcId

      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
          Description: Allow HTTP from the Internet

      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
          Description: Allow outbound traffic

      Tags:
        - Key: Name
          Value: arak-alb-sg

  # =========================
  # Application Security Group
  # =========================

  ArakAppSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: arak-app-sg
      GroupDescription: Allow application traffic from the ALB only.
      VpcId: !Ref VpcId

      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 5000
          ToPort: 5000
          SourceSecurityGroupId: !Ref ArakALBSecurityGroup
          Description: Allow application traffic from ALB

      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
          Description: Allow outbound traffic

      Tags:
        - Key: Name
          Value: arak-app-sg

  # =========================
  # Database Security Group
  # =========================

  ArakDBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: arak-db-sg
      GroupDescription: Allow SQL Server traffic from the application layer only.
      VpcId: !Ref VpcId

      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 1433
          ToPort: 1433
          SourceSecurityGroupId: !Ref ArakAppSecurityGroup
          Description: Allow SQL Server from application layer

      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
          Description: Allow outbound traffic

      Tags:
        - Key: Name
          Value: arak-db-sg

Outputs:

  ALBSecurityGroupId:
    Description: ALB Security Group ID
    Value: !Ref ArakALBSecurityGroup

  AppSecurityGroupId:
    Description: Application Security Group ID
    Value: !Ref ArakAppSecurityGroup

  DBSecurityGroupId:
    Description: Database Security Group ID
    Value: !Ref ArakDBSecurityGroup

================================================================================
FILE: CURRENT-STATE-REPORT.md
================================================================================

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

================================================================================
FILE: DOCUMENTATION/architecture-decisions.md
================================================================================

# Architecture Decision Log

This file records important design decisions for the Arak AWS Solutions Architect â€“ Associate project.

## ADR-001 â€” Use the Manara Project 1 Architecture

**Decision:** Use the "Scalable Web Application with ALB and Auto Scaling" project as the architecture target.

**Reason:** It matches the existing Arak web application and directly covers the required SAA concepts: VPC design, public/private subnets, ALB, Auto Scaling, Multi-AZ database, Security Groups, NACLs, NAT Gateway, Systems Manager, and monitoring.

**Source:** Manara project brief.

## ADR-002 â€” Keep the Existing EC2 Prototype

**Decision:** Do not delete or replace the current EC2 prototype yet.

**Reason:** The existing single-EC2 deployment is a working baseline and fallback. The final architecture will be built separately and the application will be migrated progressively.

**Status:** Accepted.

## ADR-003 â€” Separate Application Compute from the Database

**Decision:** Move the database responsibility out of the application EC2 instances and use managed RDS for the final architecture.

**Reason:** Auto Scaling works best when application instances are replaceable and do not contain the authoritative database state.

**Arak consideration:** The existing application uses SQL Server, so the initial database strategy remains SQL Server unless a later documented decision changes it.

**Status:** Implemented and validated with Amazon RDS for SQL Server.

## ADR-004 â€” Use Two Availability Zones

**Decision:** The final architecture spans two Availability Zones.

**Reason:** The selected project explicitly requires a VPC with public and private subnets across two Availability Zones and targets high availability.

## ADR-005 â€” Put ALB in Public Subnets and EC2 in Private Subnets

**Decision:** The Internet-facing Application Load Balancer uses public subnets, while Auto Scaling EC2 instances use private application subnets.

**Reason:** This separates Internet ingress from application compute and prevents direct public access to the EC2 instances.

## ADR-006 â€” Use NAT Gateway for Private Application Egress

**Decision:** The validated architecture uses a NAT Gateway in a public subnet for controlled outbound Internet access from private application subnets.

**Reason:** Private instances may need outbound access for updates and operational dependencies without becoming directly Internet-addressable.

**Availability choice:** One NAT Gateway per AZ is the production-oriented target. A single NAT Gateway may be used temporarily for a cost-constrained lab deployment only if documented.

## ADR-007 â€” Use Security Groups as the Primary Workload Firewall

**Decision:** Security Groups will define the main resource-to-resource access rules, with NACLs used as subnet-level defense in depth.

**Reason:** This keeps access rules close to the resources and follows the stateful Security Group model while still demonstrating subnet-level controls through NACLs.

## ADR-008 â€” Build Incrementally

**Decision:** Build and validate the AWS architecture incrementally, then reproduce it with Infrastructure as Code.

**Reason:** Each layer should be validated before the next layer is introduced. This reduces troubleshooting complexity and provides clear evidence for the final project documentation.

**Implementation sequence:** Networking â†’ security â†’ database â†’ compute â†’ ALB â†’ end-to-end validation â†’ CloudFormation â†’ monitoring â†’ CloudFront/WAF/Route 53 where justified.

## ADR-009 â€” Use IAM Roles Instead of AWS Access Keys

**Decision:** Use an IAM role attached to the EC2 instances through an Instance Profile.

**Reason:** EC2 instances need AWS permissions to retrieve database credentials from Secrets Manager and use Systems Manager. An IAM role avoids storing long-lived AWS access keys on application servers.

**Implementation:** IAM role `ARAK-Production-EC2-Role` is associated with the application EC2 instances through the Launch Template.

**Status:** Implemented and validated.

================================================================================
FILE: DOCUMENTATION/current-state.md
================================================================================

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

================================================================================
FILE: DOCUMENTATION/deployment-notes.md
================================================================================

# Deployment Notes

## Region

`us-east-1`

## Manual Architecture

The manual architecture was built and validated before starting CloudFormation.

## CloudFormation Network Test

- Stack: `arak-network-test`
- Template: `cloudformation/network.yaml`
- Result: `CREATE_COMPLETE`

Created resources included:

- VPC
- Public subnets
- Private application subnets
- Private database subnets
- Internet Gateway
- NAT Gateway
- Elastic IP
- Route tables
- Routes
- Subnet associations

The stack remains temporarily as deployment proof. Cleanup is intentionally deferred until evidence review is complete.

## Security CloudFormation

- Template: `cloudformation/security.yaml`
- Status: Created, not yet validated or deployed as a CloudFormation stack.
- Intended test stack: `arak-security-test`

## Load Balancer

- Load Balancer: `arak-alb`
- Scheme: Internet-facing
- IP type: IPv4
- Public subnets: `arak-public-a`, `arak-public-b`
- Target Group: `arak-app-tg`
- Protocol: HTTP
- Target port: `5000`
- Health check: `/health`
- Validation: ALB DNS `/health` returned `{"status":"healthy"}` with HTTP `200`.

================================================================================
FILE: DOCUMENTATION/manual-deployment-journey.md
================================================================================

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

================================================================================
FILE: EVIDENCE/screenshots/README.md
================================================================================

# Evidence Screenshots

Store AWS Console screenshots and validation evidence here.

Do not store credentials, secret values, or access keys in this directory.

## Networking

- `cloudformation-network-create-complete.png` - CloudFormation Resources view for `arak-network-test` with `CREATE_COMPLETE`.
- VPC, subnet, route table, and NAT Gateway evidence are represented in the CloudFormation Resources screenshot.

## Security

- `arak-alb-sg`
- `arak-app-sg`
- `arak-db-sg`

## Compute

- Launch Template
- Auto Scaling Group
- Instance Refresh
- Private EC2 instance

## Database

- RDS instance
- RDS subnet group
- RDS security configuration

## Load Balancer

- `arak-alb`
- `arak-app-tg`
- Target health
- ALB DNS health response

## Application Validation

Expected response: `{"status":"healthy"}`  
Expected HTTP status: `200`

Do not store credentials, secret values, or access keys in this directory.

================================================================================
FILE: PROJECT-REQUIREMENTS.md
================================================================================

# Project Requirements

## Source

This project follows the **AWS Solutions Architect - Associate Graduation Project Ideas** brief provided by Manara.

## Required Deliverables

1. **Solution Architecture Diagram**
   - A visual representation of the solution architecture.
   - Free diagramming tools such as Lucidchart or draw.io may be used.

2. **GitHub Repository**
   - A public repository containing the complete project documentation.
   - The solution architecture diagram and documentation should be included in the README.

3. **Optional Deliverable**
   - A live URL or recorded video demonstrating the deployed solution on AWS.

## Selected Project Idea

### Project 1: Scalable Web Application with ALB and Auto Scaling

**Architecture:** EC2-Based

The brief describes a production-grade web application on AWS using EC2 instances inside a properly architected VPC with public and private subnets across two Availability Zones.

The architecture is expected to provide high availability and scalability using ALB, ASG, and CloudFront for static assets. A Multi-AZ RDS instance serves as the database backend, with compute in private subnets.

## Key AWS Services Listed in the Brief

- VPC: Public and private subnets, NAT Gateway, Security Groups, NACLs
- EC2 + ASG: Launch Template and scaling policies
- ALB + WAF: Layer 7 routing and WAF rules
- CloudFront: Static asset caching
- RDS Multi-AZ: MySQL/PostgreSQL examples in the brief
- Route 53: Alias record pointing to ALB and health checks
- Systems Manager: Session Manager
- CloudWatch + SNS: Dashboards, alarms, and notifications

## Learning Outcomes Listed in the Brief

- Design VPCs with correct subnet, route table, and NAT Gateway configurations
- Build highly available architectures across multiple Availability Zones
- Configure ALB listener rules and target-group health checks
- Implement Auto Scaling with target tracking and step scaling policies
- Secure applications with WAF, Security Groups, and private subnets
- Use Systems Manager Session Manager as a bastion-free access alternative

## Arak Mapping

Arak is being mapped to this project idea instead of creating a new application. The existing application already provides a frontend, backend, authentication, and SQL Server database. The AWS work focuses on redesigning the deployment into the required scalable architecture.

## Status Rule

The repository must clearly distinguish:

- **Current Prototype:** what is actually deployed now.
- **Target Architecture:** what the final SAA project is designed to achieve.
- **Completed Evidence:** resources and tests that have been verified as implemented.

Never mark an AWS component as completed without implementation evidence.

## Implementation Status

The core architecture has been manually implemented and validated.

Implemented components include:

- VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Security Groups
- EC2 Auto Scaling Group
- Launch Template
- Dockerized ASP.NET Core backend
- Amazon RDS for SQL Server
- AWS Secrets Manager
- Application Load Balancer
- Target Group
- End-to-end health validation

CloudFormation implementation has also started with the networking layer. The `arak-network-test` stack reached `CREATE_COMPLETE` in the `us-east-1` test environment.

================================================================================
FILE: README.md
================================================================================

# Arak AWS Solutions Architect â€“ Associate Project

AWS Solutions Architect â€“ Associate graduation project based on the Arak education-management SaaS application.

## Selected Manara Project

**Project 1 â€“ Scalable Web Application with ALB and Auto Scaling**

The Manara brief requires a Solution Architecture Diagram and a public GitHub repository containing the complete project documentation. A live URL or recorded deployment demonstration is optional but encouraged.

## Current Status

The original single-EC2 deployment remains a documented fallback prototype. The scalable AWS architecture has now been manually implemented and validated end to end, including private application compute, RDS for SQL Server, Secrets Manager, Application Load Balancing, and application connectivity.

The next phase is CloudFormation Infrastructure as Code and reproducibility validation.

## Target Architecture

The validated architecture includes:

- VPC across two Availability Zones
- Public and private subnets
- Application Load Balancer
- EC2 Launch Template and Auto Scaling Group
- Managed SQL Server database with Multi-AZ deployment
- Security Groups and NACLs
- Internet Gateway and controlled private-subnet egress
- Systems Manager for administration
- CloudWatch monitoring and SNS notifications
- CloudFront, WAF, and Route 53 where justified by the final design

## Application Stack

- Frontend: React + Vite
- Backend: ASP.NET Core (.NET 9)
- ORM: Entity Framework Core
- Authentication: ASP.NET Identity / JWT
- Database: SQL Server
- Existing web server: Nginx

## Repository Structure

```text
.
â”œâ”€â”€ README.md
â”œâ”€â”€ CURRENT-STATE-REPORT.md
â”œâ”€â”€ PROJECT-REQUIREMENTS.md
â”œâ”€â”€ ARCHITECTURE/
â”‚   â”œâ”€â”€ target-architecture.md
â”‚   â””â”€â”€ diagrams/
â”œâ”€â”€ DOCUMENTATION/
â”‚   â”œâ”€â”€ current-state.md
â”‚   â”œâ”€â”€ architecture-decisions.md
â”‚   â”œâ”€â”€ deployment-notes.md
â”‚   â””â”€â”€ manual-deployment-journey.md
â”œâ”€â”€ AWS/
â”‚   â”œâ”€â”€ networking/
â”‚   â”‚   â”œâ”€â”€ README.md
â”‚   â”‚   â”œâ”€â”€ vpc-design.md
â”‚   â”‚   â””â”€â”€ vpc-deployment-checklist.md
â”‚   â”œâ”€â”€ compute/
â”‚   â”‚   â”œâ”€â”€ README.md
â”‚   â”‚   â””â”€â”€ user-data.sh
â”‚   â”œâ”€â”€ database/
â”‚   â”‚   â””â”€â”€ README.md
â”‚   â”œâ”€â”€ security/
â”‚   â”‚   â””â”€â”€ README.md
â”‚   â””â”€â”€ monitoring/
â”‚       â””â”€â”€ README.md
â”œâ”€â”€ EVIDENCE/
â”‚   â””â”€â”€ screenshots/
â”œâ”€â”€ cloudformation/
â”‚   â”œâ”€â”€ network.yaml
â”‚   â”œâ”€â”€ security.yaml
â”‚   â””â”€â”€ README.md
â””â”€â”€ CHANGELOG.md
```

## Delivery Method

Every completed architecture or deployment step will be documented and committed to this repository immediately. The repository is both the implementation record and the final project documentation.

## Current Prototype vs Final Target

### Current Prototype
Single public EC2 instance running Nginx, React, ASP.NET Core, and SQL Server locally.

### Validated AWS Architecture
Highly available and scalable AWS architecture designed around ALB, Auto Scaling, Multi-AZ networking, and a managed database.

### Next Phase
Recreate the manually validated architecture with CloudFormation and prove that it can be deployed, validated, and removed from code.

## Current AWS Progress

### Networking

- VPC `arak-vpc` created with CIDR `10.0.0.0/16`.
- Six subnets created across two Availability Zones.
- Public routing configured through an Internet Gateway.
- NAT Gateway configured for private application subnet outbound access.
- Private application route table configured.
- Private database route table configured without an Internet default route.

### Security

- `arak-alb-sg` created for the Application Load Balancer.
- `arak-app-sg` created for the application instances.
- `arak-db-sg` created for the database layer.
- RDS is private and is not publicly accessible.
- Systems Manager Session Manager is configured for EC2 administration.
- RDS credentials are managed through AWS Secrets Manager.

### Compute

- Launch Template `arak-app-template` created.
- Auto Scaling Group `arak-app-asg` created.
- Application instances run in private application subnets.
- Desired capacity: 1.
- Minimum capacity: 1.
- Maximum capacity: 2.
- Auto Scaling Instance Refresh completed successfully.
- EC2 instances use the `ARAK-Production-EC2-Role` IAM instance profile.

### Application

- Docker is installed on the application instances.
- Arak Backend image: `asdy74/arak-backend:v1`.
- Backend container: `arak-api`.
- Backend runs on port `5000`.
- Container health status validated as `healthy`.
- `/health` endpoint returns HTTP `200 OK`.

### Database

- Amazon RDS for SQL Server created.
- DB identifier: `arak-db-2`.
- RDS instance class: `db.t3.micro`.
- RDS is deployed in the private database subnets.
- DB subnet group: `arak-db-subnet-group`.
- RDS is not publicly accessible.
- EC2 -> RDS connectivity validated on TCP port `1433`.
- Backend -> RDS connectivity validated through Entity Framework Core.

### Load Balancing

- Application Load Balancer `arak-alb` created.
- Scheme: Internet-facing.
- ALB deployed across `arak-public-a` and `arak-public-b`.
- Target Group `arak-app-tg` created.
- Target Group protocol: HTTP.
- Target Group port: `5000`.
- Health check path: `/health`.
- Two application instances registered as targets.
- ALB -> Target Group -> EC2 routing validated.
- ALB DNS `/health` endpoint successfully returned HTTP `200 OK`.

### CloudFormation Networking

- `cloudformation/network.yaml` successfully validated and deployed in the AWS test environment.
- Test stack: `arak-network-test`.
- Deployment status: `CREATE_COMPLETE`.
- CloudFormation Resources view confirmed the VPC, subnets, route tables, routes, associations, Internet Gateway, NAT Gateway, and Elastic IP.
- AWS Console screenshot captured as deployment evidence.

### Current Architecture Status

The manually deployed AWS architecture is now operational and has been validated end-to-end.

The next phase is to reproduce the validated architecture using AWS CloudFormation.

### Next

- Translate Security Groups into CloudFormation.
- Validate the Security Groups template.
- Translate RDS into CloudFormation.
- Translate Launch Template and Auto Scaling into CloudFormation.
- Translate ALB and Target Group into CloudFormation.
- Add monitoring resources.
- Deploy and validate the complete architecture from CloudFormation.

================================================================================
BINARY FILES
================================================================================

- EVIDENCE/screenshots/alb_health check.jpg
- EVIDENCE/screenshots/alb1.png
- EVIDENCE/screenshots/alb2.jpg
- EVIDENCE/screenshots/alb3.jpg
- EVIDENCE/screenshots/alp creation.png
- EVIDENCE/screenshots/alp settings.png
- EVIDENCE/screenshots/asg.png
- EVIDENCE/screenshots/asg2.png
- EVIDENCE/screenshots/asg3.png
- EVIDENCE/screenshots/cloudformation-network-create-complete.png
- EVIDENCE/screenshots/db(rds).png
- EVIDENCE/screenshots/ec2_template.jpg
- EVIDENCE/screenshots/nat1.jpg
- EVIDENCE/screenshots/target_group.png
- EVIDENCE/screenshots/vpc1.jpg
- EVIDENCE/screenshots/vpc2.jpg
- EVIDENCE/screenshots/vpc3.jpg
- EVIDENCE/screenshots/vpc4.jpg
