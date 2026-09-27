# Compute and Auto Scaling

## Application Compute

The application tier uses Amazon EC2 behind an Application Load Balancer.

### Launch Template

- AMI: Amazon Linux 2023
- Instance type: `t3.micro` as the baseline design
- Application Security Group: `arak-app-sg`
- IAM instance profile: `ARAK-Production-EC2-Role`
- Application port: `5000`
- Health endpoint: `/health`

The application instances are placed only in private application subnets.

## Auto Scaling Group

| Setting | Design |
|---|---:|
| Minimum | 2 |
| Desired | 2 |
| Maximum | 6 |
| Availability Zones | 2 |
| Health check | ELB |
| Grace period | 300 seconds |

The Auto Scaling Group distributes instances across the two application subnets.

## Bootstrap Design

The Launch Template User Data bootstraps the application consistently:

1. Install Docker and required utilities.
2. Start Docker.
3. Pull the Arak backend image.
4. Retrieve database credentials from Secrets Manager.
5. Build the SQL Server connection string from managed parameters.
6. Start the ASP.NET Core container.
7. Expose port `5000`.

The reference bootstrap is available in [user-data.sh](user-data.sh).

No secret values should be committed to Git.

## Target Tracking Policy

Primary scaling policy:

- Metric: Average CPU utilization
- Target: 50%
- Scale-out: automatic when demand requires additional capacity
- Scale-in: automatic when capacity is no longer required

AWS documents target tracking as a policy that automatically adjusts Auto Scaling capacity around a target metric value. citeturn0search1

## Step Scaling Policy

Step scaling is documented for exceptional spikes.

Example scale-out thresholds:

| CPU condition | Adjustment |
|---|---:|
| > 70% | +1 |
| > 85% | +2 |

The policy should use CloudWatch alarms and cooldown/warmup settings that prevent rapid oscillation.

Target tracking should remain the primary policy. AWS recommends caution when combining target tracking and step scaling because policies can conflict. citeturn0search0turn0search11

## Load Balancer Health

The ALB target group uses:

- Protocol: HTTP
- Port: `5000`
- Health path: `/health`

Unhealthy instances are removed from traffic and the Auto Scaling Group can replace them.

## Systems Manager

Systems Manager Session Manager provides administrative access without requiring a public IP or a bastion host.

The EC2 IAM role provides the permissions required by the application and management services.
