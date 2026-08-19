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
