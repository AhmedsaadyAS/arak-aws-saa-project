# Arak AWS Solutions Architect – Associate Project

AWS Solutions Architect – Associate graduation project based on the Arak education-management SaaS application.

## Selected Manara Project

**Project 1 – Scalable Web Application with ALB and Auto Scaling**

The Manara brief requires a Solution Architecture Diagram and a public GitHub repository containing the complete project documentation. A live URL or recorded deployment demonstration is optional but encouraged.

## Current Status

The existing Arak deployment is a **working prototype only**. It currently runs the frontend, ASP.NET Core backend, and SQL Server on a single Ubuntu EC2 instance behind Nginx.

This prototype is intentionally kept as the baseline while the final scalable AWS architecture is designed and implemented.

## Target Architecture

The target architecture will progressively introduce:

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
├── PROJECT-REQUIREMENTS.md
├── ARCHITECTURE/
│   ├── target-architecture.md
│   └── diagrams/
├── DOCUMENTATION/
│   ├── current-state.md
│   ├── architecture-decisions.md
│   └── deployment-notes.md
├── AWS/
│   ├── networking/
│   ├── compute/
│   ├── database/
│   ├── security/
│   └── monitoring/
├── EVIDENCE/
│   └── screenshots/
└── CHANGELOG.md
```

## Delivery Method

Every completed architecture or deployment step will be documented and committed to this repository immediately. The repository is both the implementation record and the final project documentation.

## Current Prototype vs Final Target

### Current Prototype
Single public EC2 instance running Nginx, React, ASP.NET Core, and SQL Server locally.

### Final Target
Highly available and scalable AWS architecture designed around ALB, Auto Scaling, Multi-AZ networking, and a managed database.

## Progress

- [x] Repository initialized
- [x] Project scope documented
- [x] Current prototype documented
- [ ] Final architecture diagram
- [ ] VPC and subnet design
- [ ] RDS migration
- [ ] Application Load Balancer
- [ ] Launch Template
- [ ] Auto Scaling Group
- [ ] Security hardening
- [ ] Monitoring and alerting
- [ ] Optional CloudFront / WAF / Route 53
- [ ] Final evidence and submission documentation
