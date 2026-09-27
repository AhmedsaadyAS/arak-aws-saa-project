# VPC and Networking Design

## Design Goal

Create a two-AZ VPC that separates Internet-facing resources, application compute, and database resources.

## VPC

**CIDR:** `10.0.0.0/16`

| Availability Zone | Subnet | CIDR | Type | Intended resources |
|---|---|---|---|---|
| AZ-1 | Public-A | `10.0.1.0/24` | Public | ALB, NAT Gateway |
| AZ-1 | App-A | `10.0.11.0/24` | Private | EC2 Auto Scaling |
| AZ-1 | DB-A | `10.0.21.0/24` | Private | RDS |
| AZ-2 | Public-B | `10.0.2.0/24` | Public | ALB, NAT Gateway |
| AZ-2 | App-B | `10.0.12.0/24` | Private | EC2 Auto Scaling |
| AZ-2 | DB-B | `10.0.22.0/24` | Private | RDS |

## Internet Gateway

One Internet Gateway is attached to the VPC.

Public route tables use:

```text
0.0.0.0/0 -> Internet Gateway
```

## NAT Gateway

The high-availability design uses one NAT Gateway per Availability Zone.

```text
App-A -> NAT-A -> Internet Gateway
App-B -> NAT-B -> Internet Gateway
```

This keeps private application instances without public IP addresses while providing controlled outbound access.

## Database Routing

Database subnets retain the local VPC route only.

No direct Internet default route is provided to the database tier.

## Traffic Model

### Internet to application

```text
Internet
 -> Route 53
 -> CloudFront
 -> WAF
 -> ALB
 -> Target Group
 -> Private EC2
```

### Application to database

```text
Private EC2
 -> App Security Group
 -> DB Security Group
 -> RDS SQL Server :1433
```

### Private outbound traffic

```text
Private EC2
 -> NAT Gateway
 -> Internet Gateway
 -> Internet
```

## Security Groups

### ALB SG

Allow:

- TCP 80 from the public edge
- TCP 443 from the public edge

### Application SG

Allow:

- TCP 5000 from ALB SG only

### Database SG

Allow:

- TCP 1433 from Application SG only

## NACLs

Network ACLs provide subnet-level defense in depth.

Security Groups remain the primary resource-level traffic control.

## DNS and Edge

Route 53 points the public application domain to CloudFront. CloudFront provides the public edge layer and can use separate origins for the static frontend and API. AWS documents CloudFront support for S3 and Application Load Balancer origins. citeturn1search11

## Design Result

The network provides:

- Two Availability Zones
- Public/private segmentation
- Private application compute
- Private database tier
- Controlled outbound Internet access
- No direct Internet route to the database
- Clear resource-to-resource security boundaries
