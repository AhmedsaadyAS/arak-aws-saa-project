# Practical Implementation Evidence

This directory preserves the AWS Console evidence from the practical Arak deployment.

The evidence covers the deployed network foundation, compute and scaling resources, database, load balancer, target health, and application health validation.

## Evidence index

### Networking
- `vpc1.jpg` — VPC configuration
- `vpc2.jpg` — subnet configuration
- `vpc3.jpg` — routing configuration
- `vpc4.jpg` — network resources
- `nat1.jpg` — NAT Gateway
- `cloudformation-network-create-complete.png` — CloudFormation network stack reaching `CREATE_COMPLETE`

### Compute and Auto Scaling
- `ec2_template.jpg` — Launch Template
- `asg.png`, `asg2.png`, `asg3.png` — Auto Scaling Group and instance state

### Database
- `db(rds).png` — RDS configuration

### Load Balancing
- `alp creation.png` — Application Load Balancer creation
- `alp settings.png` — ALB settings
- `target_group.png` — target group
- `alb1.png`, `alb2.jpg`, `alb3.jpg` — ALB validation
- `alb_health check.jpg` — health-check validation

All screenshots are deployment evidence only; credentials, secret values, and access keys are not stored here.
