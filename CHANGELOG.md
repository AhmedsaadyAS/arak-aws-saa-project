# Changelog

## 2026-09-27

### Architecture-First Revision

- Refined the repository around the final AWS solution architecture rather than deployment status.
- Removed deployment-status reports and troubleshooting history from the submission repository.
- Removed incomplete CloudFormation artifacts.
- Removed AWS console deployment screenshots from the submission repository.
- Updated the README to present the solution architecture, request flows, security model, scalability model, monitoring, and AWS services.
- Added explicit target-tracking and step-scaling design.
- Added CloudFront, WAF, Route 53, and S3 roles to the final architecture.
- Updated the RDS design to use SQL Server Standard Edition with Multi-AZ.
- Consolidated the repository around architecture, service design, and documented decisions.

## Project Direction

The repository is intentionally maintained as an **architecture and solution-design deliverable**.

A live AWS deployment is optional for the project and is not required for the repository to communicate the proposed solution.
