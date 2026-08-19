# Security

## Security Group Flow

```text
Internet -> arak-alb-sg -> arak-app-sg -> arak-db-sg
```

### `arak-alb-sg`

The public entry point allows TCP `80` from the Internet to the Application Load Balancer.

### `arak-app-sg`

Allows TCP `5000` from `arak-alb-sg` only. The application port is not exposed directly to the Internet.

### `arak-db-sg`

Allows TCP `1433` from `arak-app-sg` only. SQL Server is not exposed publicly.

## IAM

The application EC2 instances use the IAM role `ARAK-Production-EC2-Role`, attached through an IAM Instance Profile.

The role provides AWS permissions required by the application instances without storing AWS access keys on the servers.

### Secrets Manager Access

The EC2 role allows the application instance to retrieve RDS database credentials from AWS Secrets Manager at runtime. Database credentials are not hardcoded in the application image or stored in Git.

### Systems Manager

The EC2 instances use the IAM role required for AWS Systems Manager Session Manager administration. This allows administrative access without a public IP or direct SSH access.

## NACLs

NACLs provide subnet-level defense in depth where justified. Security Groups remain the primary workload-level firewall.
