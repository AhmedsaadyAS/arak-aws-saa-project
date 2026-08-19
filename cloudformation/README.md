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
