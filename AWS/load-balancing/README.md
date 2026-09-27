# Application Load Balancer

## Role

The Application Load Balancer is the regional entry point for dynamic API traffic behind CloudFront/WAF.

## Configuration

- Scheme: Internet-facing
- Availability Zones: two
- Subnets: Public-A and Public-B
- Listener: HTTPS 443
- Optional HTTP listener: redirect to HTTPS
- Target type: Instance
- Target port: `5000`
- Health check path: `/health`

## Traffic Flow

```text
CloudFront
   |
   v
AWS WAF
   |
   v
Application Load Balancer
   |
   v
Target Group
   |
   +----> EC2 / AZ-1
   |
   +----> EC2 / AZ-2
```

## Health Checks

The target group checks:

```text
GET /health
```

Only healthy targets receive traffic.

## Security

The ALB Security Group is designed to accept HTTPS traffic from CloudFront origin-facing infrastructure. An additional secret CloudFront origin header can be used to reject requests that bypass CloudFront.

The application Security Group accepts port `5000` only from the ALB Security Group.

This prevents direct Internet access to the application instances.
