# Database

## Amazon RDS for SQL Server

The Arak application uses Amazon RDS for SQL Server as the managed database layer.

### Configuration

- Identifier: `arak-db-2`
- Engine: SQL Server Express Edition
- Instance class: `db.t3.micro`
- Port: `1433`
- Public accessibility: Disabled
- DB subnet group: `arak-db-subnet-group`
- Subnets: `arak-db-a`, `arak-db-b`

## Security

Database access is controlled through `arak-db-sg`. TCP `1433` is allowed only from `arak-app-sg`. The database does not allow public inbound access.

## Credentials

Database credentials are stored in AWS Secrets Manager. The EC2 instance retrieves them at runtime using its IAM instance role instead of storing them in the application image or repository.

## Validation

EC2-to-RDS connectivity and backend-to-RDS connectivity through Entity Framework Core were validated successfully.
