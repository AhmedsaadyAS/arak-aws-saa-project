# VPC and Networking Design

## Status

**Design phase — not deployed yet.**

This document defines the proposed network foundation for the Arak AWS Solutions Architect – Associate project. It follows the selected Manara brief: a production-grade EC2 application in a VPC with public and private subnets across two Availability Zones, with ALB, Auto Scaling, NAT Gateway, Security Groups, NACLs, and a Multi-AZ managed database.

## 1. Design Goals

- Use two Availability Zones for high availability.
- Keep the Application Load Balancer in public subnets.
- Keep application EC2 instances in private subnets.
- Keep the database in dedicated private database subnets.
- Avoid direct Internet access to application EC2 instances.
- Provide controlled outbound Internet access from private application subnets through NAT Gateway(s).
- Keep database subnets without a direct Internet route.
- Make the subnet and routing design explicit before creating AWS resources.

## 2. Proposed VPC CIDR

**VPC:** `10.0.0.0/16`

This provides enough address space for the project while leaving room for future subnets without changing the VPC CIDR.

## 3. Proposed Subnet Layout

| Availability Zone | Subnet | CIDR | Type | Intended resources |
|---|---|---|---|---|
| AZ-1 | Public-A | `10.0.1.0/24` | Public | ALB nodes, NAT Gateway |
| AZ-1 | App-A | `10.0.11.0/24` | Private | EC2 Auto Scaling Group |
| AZ-1 | DB-A | `10.0.21.0/24` | Private | RDS subnet group |
| AZ-2 | Public-B | `10.0.2.0/24` | Public | ALB nodes, NAT Gateway |
| AZ-2 | App-B | `10.0.12.0/24` | Private | EC2 Auto Scaling Group |
| AZ-2 | DB-B | `10.0.22.0/24` | Private | RDS subnet group |

The exact AWS Availability Zone names will be selected in the deployment region when the resources are created; the design intentionally refers to AZ-1 and AZ-2 rather than hard-coding names at this stage.

## 4. Internet Gateway

One Internet Gateway will be attached to the VPC.

The public route table will contain:

```text
0.0.0.0/0 -> Internet Gateway
```

This allows resources that are intentionally placed in public subnets to reach the Internet when their security controls also permit the traffic.

## 5. Public Route Table

The public route table will be associated with:

- Public-A
- Public-B

Route:

```text
VPC local route
0.0.0.0/0 -> Internet Gateway
```

The ALB requires public subnets so that it can receive Internet-facing traffic.

## 6. Private Application Route Tables

The application subnets will not have a direct route to the Internet Gateway.

For the production/high-availability target, each AZ will have a NAT Gateway in its corresponding public subnet:

```text
App-A route table:
0.0.0.0/0 -> NAT Gateway in Public-A

App-B route table:
0.0.0.0/0 -> NAT Gateway in Public-B
```

This keeps private EC2 instances private while allowing controlled outbound access for package updates, dependency retrieval, monitoring agents, or other required external connections.

### Cost note

Two NAT Gateways provide better AZ independence but cost more. A single NAT Gateway is acceptable as a temporary cost-saving lab configuration, but it would introduce a cross-AZ dependency and a single point of failure for private-subnet egress. The final production-oriented design therefore uses one NAT Gateway per AZ unless the project budget requires the lab alternative.

## 7. Database Route Tables

The DB subnets will use dedicated database route tables.

They will retain the VPC local route but will not have a default route to the Internet Gateway.

The database therefore remains isolated from direct Internet access.

## 8. Traffic Model

### User to application

1. Internet user reaches the public entry point.
2. Internet-facing ALB receives the request in the public subnets.
3. ALB forwards approved application traffic to healthy EC2 instances in the private App-A/App-B subnets.

### Application to database

1. EC2 instances initiate database connections.
2. The database Security Group allows SQL Server traffic only from the application Security Group.
3. RDS remains in the private DB subnets.

### Private outbound traffic

1. EC2 initiates an outbound connection when required.
2. Traffic goes through the AZ-local NAT Gateway.
3. NAT Gateway is located in a public subnet and uses the Internet Gateway for Internet egress.
4. Internet hosts cannot initiate a new inbound connection through the NAT Gateway to the private EC2 instance.

## 9. Security Group Plan

Security Groups will be stateful and resource-specific.

### ALB Security Group

Allow:

- TCP 80 from Internet for the initial HTTP deployment/testing path.
- TCP 443 from Internet when HTTPS is introduced.

Do not allow database access from the ALB Security Group.

### Application Security Group

Allow the application port only from the ALB Security Group.

Do not allow the application port directly from `0.0.0.0/0`.

### Database Security Group

Allow TCP 1433 only from the Application Security Group because Arak currently uses SQL Server.

No public inbound database rule will be created.

## 10. NACL Plan

Network ACLs will provide subnet-level defense in depth.

The first implementation should remain simple and avoid duplicating every Security Group rule. The design will document any custom NACL rules that are actually required.

The primary workload-level access control remains Security Groups because they are attached to the relevant resources and are stateful.

## 11. DNS and Higher-Level Edge Services

Route 53, CloudFront, and WAF are part of the expected target architecture from the project brief, but they are intentionally handled after the core VPC, ALB, Auto Scaling, and database path is working.

This keeps the implementation incremental and makes it easier to validate each layer.

## 12. Implementation Order

1. Select AWS region and two Availability Zones.
2. Create VPC `10.0.0.0/16`.
3. Create six subnets using the table above.
4. Create and attach Internet Gateway.
5. Create public route table and associations.
6. Create NAT Gateway(s) and private application route tables.
7. Create isolated database route tables.
8. Create Security Groups.
9. Create NACL configuration where required.
10. Validate the network before deploying the application layer.

## 13. What Is Not Done Yet

No VPC, subnet, route table, NAT Gateway, Security Group, or NACL from this design is claimed as deployed until deployment evidence is added to this repository.
