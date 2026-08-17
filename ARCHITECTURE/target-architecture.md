# Target Architecture

## Objective

Transform the existing Arak single-EC2 prototype into a scalable, highly available AWS architecture that matches the selected Manara Project 1 scope: **Scalable Web Application with ALB and Auto Scaling**.

## Target Request Flow

Internet users will access Arak through an edge and load-balancing layer before reaching application instances in private subnets.

Planned flow:

1. Route 53 (optional, when a domain is available)
2. CloudFront + WAF (where justified)
3. Application Load Balancer in public subnets
4. EC2 Auto Scaling Group across two Availability Zones in private subnets
5. Managed SQL Server database in private database subnets with Multi-AZ deployment

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

The current local SQL Server instance on the prototype EC2 will be migrated to Amazon RDS for SQL Server.

The application will then use the RDS endpoint instead of a database process running on the EC2 host.

## Availability and Scalability

- ALB distributes traffic across healthy application instances.
- Auto Scaling Group maintains the desired instance capacity.
- Instances are distributed across two Availability Zones.
- Health checks allow unhealthy instances to be replaced.
- RDS Multi-AZ provides database failover capability.

## Security Controls

Planned controls include:

- Security Groups with least-necessary traffic paths
- NACLs for subnet-level controls where useful
- IAM roles instead of hardcoded AWS credentials
- Systems Manager Session Manager for administrative access
- Private application and database subnets
- WAF where the final edge design uses CloudFront/ALB protection

## Observability

Planned operational services:

- CloudWatch metrics and logs
- CloudWatch alarms
- SNS notifications for important alarms

## Important Design Rule

The final architecture is a target design until each component is actually deployed and verified. Documentation will be updated after every implementation milestone.
