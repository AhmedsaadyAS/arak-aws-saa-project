# Networking

The networking design provides the foundation for the Arak AWS solution.

## VPC

- CIDR: `10.0.0.0/16`
- Two Availability Zones
- Public, private application, and private database tiers

## Subnets

| Tier | AZ-1 | AZ-2 |
|---|---|---|
| Public | `10.0.1.0/24` | `10.0.2.0/24` |
| Application | `10.0.11.0/24` | `10.0.12.0/24` |
| Database | `10.0.21.0/24` | `10.0.22.0/24` |

## Routing

Public subnets:

```text
0.0.0.0/0 -> Internet Gateway
```

Private application subnets:

```text
AZ-1 -> NAT Gateway in AZ-1
AZ-2 -> NAT Gateway in AZ-2
```

Private database subnets have no Internet default route.

## Design Principles

- ALB is public.
- EC2 is private.
- RDS is private.
- NAT provides controlled application egress.
- Two Availability Zones provide workload redundancy.
