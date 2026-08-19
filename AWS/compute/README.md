# Compute

Document EC2 Launch Templates, Auto Scaling Groups, instance refreshes, and Systems Manager configuration here.

## Launch Template

- Launch Template: `arak-app-template`
- AMI: Amazon Linux 2023
- Instance type: `t3.micro`
- IAM instance profile: `ARAK-Production-EC2-Role`
- Application Security Group: `arak-app-sg`
- Application subnets: `arak-app-a` and `arak-app-b`
- Auto Scaling Group: `arak-app-asg`
- Desired capacity: 1
- Minimum capacity: 1
- Maximum capacity: 2

The Launch Template uses User Data to bootstrap the application instance. The sanitized reference implementation is [user-data.sh](user-data.sh).

## IAM Instance Profile

Instance profile: `ARAK-Production-EC2-Role`

The Launch Template associates the EC2 instances with this IAM instance profile. The role provides the AWS permissions required by the application instances, including access to Secrets Manager and Systems Manager.

## Why User Data Is Used

The Launch Template uses User Data so that every new EC2 instance can bootstrap itself automatically. This is important for Auto Scaling because replacement instances must deploy the application without manual configuration.

## EC2 User Data

The bootstrap process:

1. Installs Docker and `jq`.
2. Starts Docker and enables it at boot.
3. Pulls the Arak backend image: `asdy74/arak-backend:v1`.
4. Retrieves the RDS credentials from AWS Secrets Manager.
5. Extracts `username` and `password` from the secret JSON.
6. Builds the SQL Server connection string using the RDS endpoint.
7. Starts the `arak-api` Docker container.
8. Exposes the backend on port `5000`.
9. Runs the application in `Production` mode.

The EC2 instance uses the `ARAK-Production-EC2-Role` IAM instance profile to access Secrets Manager. Credentials are retrieved at runtime and are not written into User Data or committed to Git.

The reference User Data intentionally contains these placeholders:

```text
SECRET_ARN="<RDS_SECRET_ARN>"
RDS_HOST="<RDS_ENDPOINT>"
```

Production values must be supplied through the deployment process or a managed template parameter mechanism. Do not replace the placeholders with secret values in this repository.

## Application Validation

- Docker container: `arak-api`
- Backend image: `asdy74/arak-backend:v1`
- Application port: `5000`
- Health endpoint: `/health`
- Expected response: `{ "status": "healthy" }`
- Validated response status: HTTP `200 OK`

The User Data configuration was used by the Launch Template to bootstrap replacement instances during the successful Auto Scaling Instance Refresh.

## Bootstrap Process

1. Install Docker and `jq`.
2. Start Docker.
3. Pull the Arak backend image.
4. Retrieve database credentials from Secrets Manager.
5. Build the SQL Server connection string.
6. Start the `arak-api` container.
7. Expose port `5000`.
8. Run the application in Production mode.
