# Edge, DNS, and Web Protection

## Route 53

Amazon Route 53 provides the public DNS layer.

The application domain uses an alias record that points to the CloudFront distribution.

## CloudFront

CloudFront is the public content-delivery layer.

The distribution uses two logical origins:

| Origin | Purpose |
|---|---|
| Application Load Balancer | React/Vite frontend and ASP.NET Core API |

Example behavior routing:

| Path | Origin |
|---|---|
| `/*` | ALB |
| `/api/*` | ALB |

CloudFront supports both S3 and Application Load Balancer origins.

## AWS WAF

AWS WAF is attached to the CloudFront distribution.

Recommended protections:

- AWS Managed Rules
- Common web exploit protection
- Known bad input protection
- Rate-based rule
- WAF logging

## HTTPS

The public application uses HTTPS.

The design includes an ACM certificate for the application domain and CloudFront HTTPS enforcement.

## Origin Protection

The ALB is protected so that application traffic is expected to enter through CloudFront. The design can use the AWS-managed CloudFront origin-facing prefix list on the ALB Security Group and a secret custom CloudFront origin header as defense in depth. AWS documents both approaches for restricting direct access to an internet-facing ALB origin.

## Security Objective

The edge layer provides:

1. DNS resolution
2. Global content delivery
3. Static asset caching
4. TLS termination
5. Web request filtering
6. Controlled forwarding to the frontend and API origins
