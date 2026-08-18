# AWS CloudFormation IaC

This directory is the source of truth for recreating the Arak AWS SAA project infrastructure.

## Purpose

We build and validate the AWS architecture manually first so the concepts are understood. After each AWS component is completed, its CloudFormation equivalent will be added here.

The final goal is to be able to delete the lab environment and recreate the complete architecture from this code before the project demonstration, then delete the deployed resources again to avoid unnecessary ongoing AWS costs.

## Workflow

1. Design the component.
2. Build it manually in AWS.
3. Validate it.
4. Document the real configuration and relationships.
5. Add the CloudFormation code here.
6. Review the code before deployment.
7. Test CloudFormation deployment.
8. Capture project evidence.
9. Recreate the full environment from CloudFormation before the final demo.
10. Delete the stack/resources after the demo.

## Planned files

- `network.yaml` — VPC, subnets, route tables, gateways and networking resources.
- `security.yaml` — Security Groups and related security resources.
- `database.yaml` — RDS and database networking configuration.
- `compute.yaml` — Launch Template and Auto Scaling resources.
- `load-balancer.yaml` — ALB, target groups and listeners.
- `monitoring.yaml` — CloudWatch and monitoring resources.
- `main.yaml` — Final orchestration/entry point if the architecture benefits from nested or modular stacks.

## Current state
## Current Architecture Progress

### Networking
- VPC and subnet architecture completed.
- Public and private routing completed.
- NAT Gateway configured for private application outbound access.
- Database subnets have no Internet default route.
- Security Groups created for ALB, Application, and Database layers.

### Compute
- Launch Template created.
- Auto Scaling Group created.
- Application instances are deployed in private App subnets.
- Current desired capacity is 1 instance.
- Scaling range is 1–2 instances.

### Next
- Prepare Arak Backend deployment/bootstrap.
- Update Launch Template with application startup configuration.
- Create Target Group.
- Create Application Load Balancer.
- Connect ALB → Target Group → ASG.
### Completed manually

- VPC: `10.0.0.0/16`
- Six subnets across two Availability Zones
- Internet Gateway attached to the VPC
- Public route table
- Public default route: `0.0.0.0/0` -> Internet Gateway
  - NAT Gateway: `arak-nat-a`
  - Type: Public NAT Gateway
  - Subnet: `arak-public-a`
  - Elastic IP: allocated
  - Purpose: provide outbound Internet access for private application subnets
- Private App Route Table: `arak-private-app-rt`
  - Associated with `arak-app-a` and `arak-app-b`
  - Default route: `0.0.0.0/0` → `arak-nat-a`
- Private DB Route Table: `arak-private-db-rt`
  - Associated with `arak-db-a` and `arak-db-b`
  - No Internet default route
  - 
  - 3 Security Groups created:
  - `arak-alb-sg` — HTTP traffic from the Internet to the ALB
  - `arak-app-sg` — application traffic from the ALB only
  - `arak-db-sg` — SQL Server traffic from the application layer only
 
  - - Compute Layer:
  - Launch Template: `arak-app-template`
  - AMI: Amazon Linux 2023
  - Instance type: `t3.micro`
  - Security Group: `arak-app-sg`
  - Auto Scaling Group: `arak-app-asg`
  - Desired capacity: 1
  - Minimum capacity: 1
  - Maximum capacity: 2
  - App subnets: `arak-app-a`, `arak-app-b`
  - Availability Zones: `us-east-1a`, `us-east-1b`
  - Health check: EC2

### CloudFormation status

Templates are being created incrementally. We will not add placeholder infrastructure just for the sake of filling files; each template should correspond to an understood and validated AWS component.

Next networking item: NAT Gateway and private application routing.
- [ ] Translate NAT Gateway into CloudFormation
- [ ] Translate private application routing into CloudFormation
- [ ] Translate private database routing into CloudFormation
- [ ] Validate the complete networking stack through CloudFormation
- [ ] Translate Security Groups into CloudFormation
- [ ] Validate Security Group rules through CloudFormation
