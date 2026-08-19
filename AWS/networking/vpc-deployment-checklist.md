# VPC Deployment Checklist

## Status

**Complete — networking foundation manually implemented and validated.**

This checklist turns the approved VPC design into AWS resources. The deployment is being completed in small validated steps, with evidence added to `EVIDENCE/screenshots/` and the documentation updated after each successful stage.

## Phase 1 — Region and Availability Zones

- [x] Confirm AWS region — `us-east-1`
- [x] Confirm two Availability Zones available in the selected region
- [x] Record the selected AZ IDs/names in deployment notes — `us-east-1a`, `us-east-1b`

## Phase 2 — VPC Foundation

- [x] Create VPC: `10.0.0.0/16`
- [x] Enable DNS resolution
- [x] Enable DNS hostnames
- [x] Create and attach Internet Gateway — `arak-igw`
- [ ] Record VPC ID and IGW ID in deployment notes

## Phase 3 — Subnets

- [x] Public-A: `10.0.1.0/24` — `arak-public-a` — `us-east-1a`
- [x] Public-B: `10.0.2.0/24` — `arak-public-b` — `us-east-1b`
- [x] App-A: `10.0.11.0/24` — `arak-app-a` — `us-east-1a`
- [x] App-B: `10.0.12.0/24` — `arak-app-b` — `us-east-1b`
- [x] DB-A: `10.0.21.0/24` — `arak-db-a` — `us-east-1a`
- [x] DB-B: `10.0.22.0/24` — `arak-db-b` — `us-east-1b`

## Phase 4 — Routing

- [x] Public route table with `0.0.0.0/0 -> IGW` — `arak-public-rt`
- [x] Associate Public-A and Public-B
- [x] Create NAT Gateway(s) in public subnet(s) — `arak-nat-a`
- [x] App-A route: `0.0.0.0/0 -> NAT Gateway`
- [x] App-B route: `0.0.0.0/0 -> NAT Gateway`
- [x] Associate App-A and App-B with private route tables
- [x] Create DB route table(s) with no Internet default route
- [x] Associate DB-A and DB-B

## Phase 5 — Security Groups

- [x] ALB Security Group — `arak-alb-sg`
- [x] Application Security Group — `arak-app-sg`
- [x] Database Security Group — `arak-db-sg`
- [x] Verify database TCP 1433 is allowed only from the Application Security Group
- [x] Verify application traffic is allowed only from the ALB Security Group

## Phase 6 — NACLs

- [x] Review default NACL behavior
- [x] Add custom NACL rules only when justified by the design
- [x] Document any custom rules

## Validation

- [x] Verify subnet route associations
- [x] Verify private subnets have no direct IGW route
- [x] Verify DB subnets have no Internet default route
- [x] Verify NAT Gateway state is Available
- [ ] Capture evidence screenshots
- [ ] Update deployment notes with resource IDs
- [ ] Mark this checklist complete only after validation

## Cost / HA Note

The target design prefers one NAT Gateway per AZ for AZ independence. If the lab budget requires a single NAT Gateway, document it explicitly as a temporary cost optimization and note the resulting single point of failure for private-subnet Internet egress.
