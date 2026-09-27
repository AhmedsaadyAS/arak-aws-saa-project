# Frontend Architecture

## React/Vite Frontend

The existing Arak frontend is built with React and Vite.

The production build produces static assets that do not require a running application server.

## Amazon S3

The production React/Vite build is served by the existing Nginx web layer on the application instances. CloudFront sits in front of the ALB and caches static frontend assets at the edge.

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
Application Load Balancer
 |
 v
Nginx / React + ASP.NET Core API
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
- The API remains behind the ALB and private EC2 instances.
