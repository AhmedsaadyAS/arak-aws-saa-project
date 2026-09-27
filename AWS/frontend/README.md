# Frontend Architecture

## React/Vite Frontend

The existing Arak frontend is built with React and Vite.

The production build produces static assets that are served by the Nginx web layer on the private application instances.

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

CloudFront caches static frontend assets at the edge while forwarding application requests to the ALB origin.

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
ASP.NET Core API :5000
```

## Benefits

- Static assets are cached at edge locations.
- Frontend and backend are delivered through the same public edge.
- The API remains behind the ALB and private EC2 instances.
