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
