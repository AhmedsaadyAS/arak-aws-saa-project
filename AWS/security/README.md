# Security Architecture

## Security Boundary

```text
Internet
   |
   v
Route 53
   |
   v
CloudFront + WAF
   |
   v
ALB
   |
   v
Private EC2
   |
   v
Private RDS
```

## Security Groups

### ALB Security Group

Allows HTTPS traffic from the CloudFront origin-facing managed prefix list. A secret CloudFront origin header can be used as an additional origin-access control. Direct public access to the ALB is not part of the intended request path.

### Application Security Group

Allows TCP `5000` only from the ALB Security Group.

### Database Security Group

Allows TCP `1433` only from the Application Security Group.

## WAF

AWS WAF is positioned at the public web layer.

Recommended controls:

- AWS Managed Rules
- Common web exploit protection
- Known bad input protection
- Rate-based rule
- Logging for security analysis

## IAM

EC2 uses an IAM role through an Instance Profile.

The role provides the minimum AWS permissions required for:

- Secrets Manager
- Systems Manager
- CloudWatch/operational integration where required

Long-lived AWS access keys are not stored on application instances.

## Secrets Manager

Database credentials are stored in Secrets Manager and retrieved at runtime.

Secrets are never committed to Git.

## Systems Manager

Session Manager provides bastion-free administration.

The application instances remain private and do not require public SSH access.

## NACLs

NACLs provide subnet-level defense in depth.

Security Groups remain the primary resource-level firewall.

## Encryption

The design uses:

- HTTPS/TLS at the public edge
- RDS encryption at rest
- S3 server-side encryption for frontend assets
- Secrets Manager for sensitive credentials
