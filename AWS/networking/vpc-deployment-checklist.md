# VPC Deployment Checklist

## Status

**Next execution step — not started yet.**

This checklist turns the approved VPC design into AWS resources. The deployment should be completed in small validated steps, with evidence added to `EVIDENCE/screenshots/` and the documentation updated after each successful stage.

## Phase 1 — Region and Availability Zones

- [ ] Confirm AWS region
- [ ] Confirm two Availability Zones available in the selected region
- [ ] Record the selected AZ IDs/names in deployment notes

## Phase 2 — VPC Foundation

- [ ] Create VPC: `10.0.0.0/16`
- [ ] Enable DNS resolution
- [ ] Enable DNS hostnames
- [ ] Create and attach Internet Gateway
- [ ] Record VPC ID and IGW ID

## Phase 3 — Subnets

- [ ] Public-A: `10.0.1.0/24`
- [ ] Public-B: `10.0.2.0/24`
- [ ] App-A: `10.0.11.0/24`
- [ ] App-B: `10.0.12.0/24`
- [ ] DB-A: `10.0.21.0/24`
- [ ] DB-B: `10.0.22.0/24`

## Phase 4 — Routing

- [ ] Public route table with `0.0.0.0/0 -> IGW`
- [ ] Associate Public-A and Public-B
- [ ] Create NAT Gateway(s) in public subnet(s)
- [ ] App-A route: `0.0.0.0/0 -> NAT Gateway`
- [ ] App-B route: `0.0.0.0/0 -> NAT Gateway`
- [ ] Associate App-A and App-B with private route tables
- [ ] Create DB route table(s) with no Internet default route
- [ ] Associate DB-A and DB-B

## Phase 5 — Security Groups

- [ ] ALB Security Group
- [ ] Application Security Group
- [ ] Database Security Group
- [ ] Verify database TCP 1433 is allowed only from the Application Security Group
- [ ] Verify application traffic is allowed only from the ALB Security Group

## Phase 6 — NACLs

- [ ] Review default NACL behavior
- [ ] Add custom NACL rules only when justified by the design
- [ ] Document any custom rules

## Validation

- [ ] Verify subnet route associations
- [ ] Verify private subnets have no direct IGW route
- [ ] Verify DB subnets have no Internet default route
- [ ] Verify NAT Gateway state is Available
- [ ] Capture evidence screenshots
- [ ] Update deployment notes with resource IDs
- [ ] Mark this checklist complete only after validation

## Cost / HA Note

The target design prefers one NAT Gateway per AZ for AZ independence. If the lab budget requires a single NAT Gateway, document it explicitly as a temporary cost optimization and note the resulting single point of failure for private-subnet Internet egress.
