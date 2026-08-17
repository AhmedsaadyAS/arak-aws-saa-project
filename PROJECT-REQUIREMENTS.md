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
