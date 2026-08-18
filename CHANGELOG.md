# Changelog

All meaningful project progress is recorded here as the AWS architecture is designed and implemented.

## 2026-08-18

### AWS Networking — VPC Foundation

- Created the `arak-vpc` VPC using CIDR `10.0.0.0/16`.
- Created two Availability Zone layers in `us-east-1`: `us-east-1a` and `us-east-1b`.
- Created the six planned subnets:
  - `arak-public-a` — `10.0.1.0/24` — `us-east-1a`
  - `arak-public-b` — `10.0.2.0/24` — `us-east-1b`
  - `arak-app-a` — `10.0.11.0/24` — `us-east-1a`
  - `arak-app-b` — `10.0.12.0/24` — `us-east-1b`
  - `arak-db-a` — `10.0.21.0/24` — `us-east-1a`
  - `arak-db-b` — `10.0.22.0/24` — `us-east-1b`
- Created and attached the `arak-igw` Internet Gateway to `arak-vpc`.
- Created the `arak-public-rt` route table.
- Associated `arak-public-a` and `arak-public-b` with `arak-public-rt`.
- Added the public default route `0.0.0.0/0 -> Internet Gateway`.

### Current architecture status

The VPC foundation and public routing are now **deployed in AWS**. The private application routing, NAT Gateway strategy, DB routing, Security Groups, and application/database deployment are still pending.

### Next step

Create and validate the NAT Gateway strategy, then configure private application route tables so the App subnets can reach the Internet through NAT without receiving direct Internet traffic through an Internet Gateway.

## 2026-08-17

### Documentation / Architecture

- Created the public project repository.
- Added the initial project README and requirements documentation.
- Documented the current Arak single-EC2 prototype.
- Added the target architecture documentation.
- Added the proposed VPC and networking design.
- Added the initial architecture decision log.

### Current architecture status

The VPC design was **proposed and documented only** at this stage. AWS networking deployment had not started yet.
