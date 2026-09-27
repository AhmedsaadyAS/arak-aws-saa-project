# ARAK AWS Architecture Diagram

This directory contains the visual architecture diagram for the project.

## Diagram

![ARAK AWS Solution Architecture](./aws.jfif)

The diagram represents the solution architecture described throughout the repository.

## Main Layers

1. Route 53
2. CloudFront
3. AWS WAF
4. Application Load Balancer
5. EC2 Auto Scaling Group
6. Amazon RDS for SQL Server
7. NAT Gateway and VPC networking
8. IAM, Secrets Manager, Systems Manager
9. CloudWatch and SNS

## Network Layout

### AZ-1

| Tier | CIDR |
|---|---|
| Public | `10.0.1.0/24` |
| Private Application | `10.0.11.0/24` |
| Private Database | `10.0.21.0/24` |

### AZ-2

| Tier | CIDR |
|---|---|
| Public | `10.0.2.0/24` |
| Private Application | `10.0.12.0/24` |
| Private Database | `10.0.22.0/24` |

## Request Paths

### Request path

```text
User
  -> Route 53
  -> CloudFront + WAF
  -> Application Load Balancer
  -> Target Group
  -> EC2 Auto Scaling Group
  -> React/Vite + Nginx / ASP.NET Core API
  -> RDS SQL Server
```

CloudFront provides the public edge and caching layer in front of the Application Load Balancer.

## Design Notes

- ALB spans both public subnets.
- EC2 instances are private.
- RDS is private and Multi-AZ.
- Application traffic uses port `5000`.
- SQL Server traffic uses port `1433`.
- CloudWatch and SNS provide observability and alerting.
