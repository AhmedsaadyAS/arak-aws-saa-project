# Networking

## Manual Architecture

The network foundation was manually implemented and validated in `us-east-1`.

- VPC: `arak-vpc`, CIDR `10.0.0.0/16`
- Availability Zones: `us-east-1a`, `us-east-1b`
- Public subnets: `arak-public-a`, `arak-public-b`
- Private application subnets: `arak-app-a`, `arak-app-b`
- Private database subnets: `arak-db-a`, `arak-db-b`
- Internet Gateway: `arak-igw`
- Public route table: `arak-public-rt`
- Private application route table: `arak-private-app-rt`
- Private database route table: `arak-private-db-rt`

## NAT Gateway Implementation

The production-oriented design prefers one NAT Gateway per Availability Zone.

For the current lab implementation, a single NAT Gateway named `arak-nat-a` was deployed in Public-A. Both private application subnets use the private application route table that routes outbound traffic through this NAT Gateway.

This is a cost-optimized lab configuration and introduces a potential cross-AZ dependency for private-subnet egress.

## CloudFormation Validation

The `cloudformation/network.yaml` template was deployed as stack `arak-network-test` in `us-east-1` and reached `CREATE_COMPLETE`. The stack created the VPC, six subnets, gateways, route tables, routes, and subnet associations.
