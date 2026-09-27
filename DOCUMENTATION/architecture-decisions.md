# Architecture Decision Log

This document records the main architecture decisions for the Arak AWS Solutions Architect – Associate project.

## ADR-001 — Use Manara Project 1

**Decision:** Use the "Scalable Web Application with ALB and Auto Scaling" project.

**Reason:** It matches the existing Arak web application and covers the required SAA concepts: VPC design, public/private subnets, ALB, Auto Scaling, Multi-AZ database, Security Groups, NACLs, NAT Gateway, Systems Manager, and monitoring.

## ADR-002 — Keep the Existing Arak Application

**Decision:** Reuse the existing Arak React/Vite frontend and ASP.NET Core backend.

**Reason:** The project is focused on AWS architecture rather than building a new application.

## ADR-003 — Separate Application Compute from the Database

**Decision:** Application compute runs on EC2 while the database is provided by Amazon RDS for SQL Server.

**Reason:** Auto Scaling requires replaceable application instances, while database state should remain in a managed service.

## ADR-004 — Use Two Availability Zones

**Decision:** Spread the public, application, and database layers across two Availability Zones.

**Reason:** This provides workload redundancy and supports the high-availability objective of the selected project.

## ADR-005 — Public ALB, Private EC2

**Decision:** Place the Application Load Balancer in public subnets and application instances in private subnets.

**Reason:** Internet ingress is separated from application compute.

## ADR-006 — Use CloudFront and WAF at the Edge

**Decision:** Use Route 53, CloudFront, and AWS WAF as the public edge layer.

**Reason:** CloudFront provides global delivery and caching, while WAF provides web-layer protection. CloudFront can use S3 and ALB origins, allowing static frontend content and dynamic API traffic to follow separate paths. citeturn1search11

## ADR-007 — Use S3 for the Static Frontend

**Decision:** Host the production React/Vite build as static assets in Amazon S3 and deliver them through CloudFront.

**Reason:** The frontend is static after the build and is therefore a suitable CDN-backed object-storage workload.

## ADR-008 — Use NAT Gateway Per Availability Zone

**Decision:** Provide an AZ-local NAT Gateway for private application egress.

**Reason:** This avoids making private-subnet Internet egress dependent on a single Availability Zone.

## ADR-009 — Security Groups as the Primary Firewall

**Decision:** Use Security Groups for resource-to-resource access and NACLs as subnet-level defense in depth.

**Reason:** Security Groups provide clear stateful controls between ALB, application, and database layers.

## ADR-010 — Target Tracking as the Primary Scaling Policy

**Decision:** Use target tracking on average EC2 CPU utilization with a 50% target.

**Reason:** Target tracking automatically adjusts capacity around the selected utilization target. citeturn0search1

## ADR-011 — Step Scaling for Exceptional Spikes

**Decision:** Document step scaling as an advanced scale-out mechanism for unusually high utilization.

**Reason:** Step scaling allows larger capacity adjustments at defined thresholds. It must be designed carefully alongside target tracking because conflicting policies can cause undesirable scaling behavior. citeturn0search0turn0search11

## ADR-012 — Multi-AZ RDS for SQL Server

**Decision:** Use Amazon RDS for SQL Server with a Multi-AZ deployment.

**Reason:** RDS provides managed database operations and automatic failover for supported SQL Server Multi-AZ configurations. SQL Server Standard Edition is selected for the architecture. citeturn0search4

## ADR-013 — Secrets Manager for Database Credentials

**Decision:** Store database credentials in AWS Secrets Manager.

**Reason:** Application instances should retrieve secrets at runtime rather than embedding credentials in images, source code, or User Data.

## ADR-014 — Systems Manager Session Manager

**Decision:** Use Systems Manager Session Manager for administrative access.

**Reason:** Application instances remain private and do not require public SSH access or a bastion host.

## ADR-015 — CloudWatch and SNS

**Decision:** Use CloudWatch for metrics, alarms, dashboards, and SNS for notifications.

**Reason:** The architecture needs visibility into ALB health, EC2 capacity, scaling behavior, and RDS health.

## Design Principle

The repository is architecture-first. The required deliverable is the documented AWS solution and its architecture diagram; deployment execution is outside the required project scope.
