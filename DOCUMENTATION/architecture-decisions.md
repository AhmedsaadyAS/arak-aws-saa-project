# Architecture Decision Log

This file records important design decisions for the Arak AWS Solutions Architect – Associate project.

## ADR-001 — Use the Manara Project 1 Architecture

**Decision:** Use the "Scalable Web Application with ALB and Auto Scaling" project as the architecture target.

**Reason:** It matches the existing Arak web application and directly covers the required SAA concepts: VPC design, public/private subnets, ALB, Auto Scaling, Multi-AZ database, Security Groups, NACLs, NAT Gateway, Systems Manager, and monitoring.

**Source:** Manara project brief.

## ADR-002 — Keep the Existing EC2 Prototype

**Decision:** Do not delete or replace the current EC2 prototype yet.

**Reason:** The existing single-EC2 deployment is a working baseline and fallback. The final architecture will be built separately and the application will be migrated progressively.

**Status:** Accepted.

## ADR-003 — Separate Application Compute from the Database

**Decision:** Move the database responsibility out of the application EC2 instances and use managed RDS for the final architecture.

**Reason:** Auto Scaling works best when application instances are replaceable and do not contain the authoritative database state.

**Arak consideration:** The existing application uses SQL Server, so the initial database strategy remains SQL Server unless a later documented decision changes it.

## ADR-004 — Use Two Availability Zones

**Decision:** The final architecture will span two Availability Zones.

**Reason:** The selected project explicitly requires a VPC with public and private subnets across two Availability Zones and targets high availability.

## ADR-005 — Put ALB in Public Subnets and EC2 in Private Subnets

**Decision:** The Internet-facing Application Load Balancer will use public subnets, while Auto Scaling EC2 instances will use private application subnets.

**Reason:** This separates Internet ingress from application compute and prevents direct public access to the EC2 instances.

## ADR-006 — Use NAT Gateway for Private Application Egress

**Decision:** The target architecture uses NAT Gateway(s) in public subnets for controlled outbound Internet access from private application subnets.

**Reason:** Private instances may need outbound access for updates and operational dependencies without becoming directly Internet-addressable.

**Availability choice:** One NAT Gateway per AZ is the production-oriented target. A single NAT Gateway may be used temporarily for a cost-constrained lab deployment only if documented.

## ADR-007 — Use Security Groups as the Primary Workload Firewall

**Decision:** Security Groups will define the main resource-to-resource access rules, with NACLs used as subnet-level defense in depth.

**Reason:** This keeps access rules close to the resources and follows the stateful Security Group model while still demonstrating subnet-level controls through NACLs.

## ADR-008 — Build Incrementally

**Decision:** Do not deploy all AWS services at once.

**Reason:** Each layer should be validated before the next layer is introduced. This reduces troubleshooting complexity and provides clear evidence for the final project documentation.

**Implementation sequence:** Networking → database → application baseline → ALB → Launch Template → Auto Scaling → security/operations → CloudFront/WAF/Route 53 where justified.
