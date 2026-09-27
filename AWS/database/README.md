# Database

## Amazon RDS for SQL Server

Amazon RDS provides the managed relational database layer for Arak.

### Design Configuration

- Engine: Microsoft SQL Server
- Edition: Standard Edition
- Port: `1433`
- Public accessibility: Disabled
- DB subnet group: private DB subnets in two Availability Zones
- Multi-AZ: Enabled
- Encryption at rest: Enabled
- Automated backups: Enabled

SQL Server Standard Edition is used in the architecture so the selected Multi-AZ design is compatible with supported RDS SQL Server high-availability configurations. AWS documents Multi-AZ support for SQL Server editions and versions including Standard Edition.

## Network Security

The database Security Group allows:

```text
TCP 1433
Source: Application Security Group
```

No public inbound database rule is used.

## Credentials

Database credentials are stored in AWS Secrets Manager.

The application retrieves credentials at runtime through its EC2 IAM role rather than storing passwords in the container image or repository.

## Availability

The RDS DB subnet group spans two Availability Zones and the database uses a Multi-AZ deployment for automatic failover.

## Backup and Recovery

The design includes:

- Automated backups
- Point-in-time recovery
- Manual snapshots before major changes
- CloudWatch monitoring for database health
