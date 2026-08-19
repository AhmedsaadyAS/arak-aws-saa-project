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
