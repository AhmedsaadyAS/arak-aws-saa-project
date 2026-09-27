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
   - A live URL or recorded video demonstrating the solution on AWS.

## Selected Project Idea

### Project 1: Scalable Web Application with ALB and Auto Scaling

**Architecture:** EC2-Based

The solution is designed as a production-oriented web application on AWS using EC2 instances inside a properly architected VPC with public and private subnets across two Availability Zones.

The architecture provides high availability and scalability using an Application Load Balancer, Auto Scaling, and CloudFront. A Multi-AZ RDS deployment provides the managed database layer, with application compute in private subnets.

## Key AWS Services

- VPC: public/private subnets, NAT Gateway, Security Groups, NACLs
- EC2 + ASG: Launch Template and scaling policies
- ALB + WAF: Layer 7 routing and web protection
- CloudFront: static asset delivery and caching
- RDS Multi-AZ: managed relational database
- Route 53: DNS and alias routing
- Systems Manager: Session Manager
- CloudWatch + SNS: dashboards, alarms, and notifications

## Learning Outcomes

- Design VPCs with correct subnet, route table, and NAT Gateway configurations
- Build highly available architectures across multiple Availability Zones
- Configure ALB listener rules and target-group health checks
- Design Auto Scaling with target tracking and step scaling policies
- Secure applications with WAF, Security Groups, NACLs, and private subnets
- Use Systems Manager Session Manager as a bastion-free access alternative

## Arak Mapping

Arak is mapped to the selected project instead of creating a new application. The existing application provides a React/Vite frontend, ASP.NET Core backend, authentication, and SQL Server database.

The AWS work focuses on redesigning the application deployment into a scalable, highly available architecture.

## Architecture Scope

The repository documents the intended AWS solution architecture, including the network topology, security boundaries, application tier, database tier, edge services, scaling model, monitoring, and operational access.

A live deployment is optional for the project deliverable, so deployment execution is outside the repository's required scope.
