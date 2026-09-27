# Frontend Architecture

## React/Vite Frontend

The existing Arak frontend is built with React and Vite.

The production build produces static assets that do not require a running application server.

## Amazon S3

The production frontend is designed to be stored in a private S3 bucket.

The bucket is not intended to be directly exposed as a public website.

CloudFront is used as the public delivery layer.

## CloudFront Flow

```text
User
 |
 v
Route 53
 |
 v
CloudFront + WAF
 |
 v
S3
 |
 v
React/Vite Static Assets
```

## API Integration

Frontend API requests use the same application domain and are routed through CloudFront to the Application Load Balancer.

```text
React Frontend
     |
     v
CloudFront
     |
     v
ALB
     |
     v
ASP.NET Core API
```

## Benefits

- Static assets are cached at edge locations.
- Frontend compute is separated from backend compute.
- S3 provides durable object storage for the frontend build.
- The API remains behind the ALB and private EC2 instances.
