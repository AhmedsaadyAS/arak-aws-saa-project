# Arak AWS Solutions Architect – Associate Project

AWS Solutions Architect – Associate graduation project based on the Arak education-management SaaS application.

## Selected Manara Project

**Project 1 – Scalable Web Application with ALB and Auto Scaling**

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
├── README.md
├── CURRENT-STATE-REPORT.md
├── PROJECT-REQUIREMENTS.md
├── ARCHITECTURE/
│   ├── target-architecture.md
│   └── diagrams/
├── DOCUMENTATION/
│   ├── current-state.md
│   ├── architecture-decisions.md
│   ├── deployment-notes.md
│   └── manual-deployment-journey.md
├── AWS/
│   ├── networking/
│   │   ├── README.md
│   │   ├── vpc-design.md
│   │   └── vpc-deployment-checklist.md
│   ├── compute/
│   │   ├── README.md
│   │   └── user-data.sh
│   ├── database/
│   │   └── README.md
│   ├── security/
│   │   └── README.md
│   └── monitoring/
│       └── README.md
├── EVIDENCE/
│   └── screenshots/
├── cloudformation/
│   ├── network.yaml
│   ├── security.yaml
│   └── README.md
└── CHANGELOG.md
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
