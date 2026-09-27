# Edge, DNS, and Web Protection

## Route 53

Amazon Route 53 provides the public DNS layer.

The application domain uses an alias record that points to the CloudFront distribution.

## CloudFront

CloudFront is the public content-delivery layer.

The Application Load Balancer is the application origin for the frontend and API.

Example behavior routing:

| Path | Origin |
|---|---|
| `/*` | Application Load Balancer |
| `/api/*` | Application Load Balancer |

CloudFront provides caching for static frontend assets while forwarding application requests to the ALB.

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

The ALB is protected so that application traffic is expected to enter through CloudFront. The design can use the AWS-managed CloudFront origin-facing prefix list on the ALB Security Group and a secret custom CloudFront origin header as defense in depth.

## Security Objective

The edge layer provides:

1. DNS resolution
2. Global content delivery
3. Static asset caching
4. TLS termination
5. Web request filtering
6. Controlled forwarding to the frontend and API origin
