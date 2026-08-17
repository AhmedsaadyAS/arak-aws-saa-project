# Current State

## Application

Arak is an education-management SaaS application.

### Stack

- Frontend: React + Vite
- Backend: ASP.NET Core on .NET 9
- ORM: Entity Framework Core
- Authentication: ASP.NET Identity with roles and JWT login
- Database: SQL Server
- Reverse proxy/web server: Nginx
- Backend process management: systemd

## Current AWS Prototype

The current deployment is a single Ubuntu EC2 instance used as a working prototype.

The instance currently contains:

- Nginx serving the React production build
- ASP.NET Core API
- SQL Server on the same host

The public request path is:

Internet → EC2 → Nginx → React / API

The API is internally proxied by Nginx to the ASP.NET Core process.

## Important Prototype Status

This deployment is **not** the final SAA architecture.

The current prototype does not yet verify the following final architecture components:

- Application Load Balancer
- Auto Scaling Group
- Launch Template
- Multi-AZ VPC design
- Public/private subnet separation for the final application
- NAT Gateway architecture
- RDS Multi-AZ
- CloudFront
- Route 53
- WAF
- CloudWatch dashboards and SNS alerting
- Systems Manager Session Manager design
- Final IAM least-privilege architecture

## Known Deployment Baseline

The prototype was successfully configured to serve the frontend through Nginx and proxy `/api/` requests internally to the backend.

The prototype should be preserved as a fallback baseline while the final AWS architecture is built.

## Security Note

Credentials must never be committed to this repository. Any previously exposed credentials are treated as a security issue and must not be copied into documentation.
