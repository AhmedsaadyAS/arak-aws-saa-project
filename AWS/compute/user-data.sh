#!/bin/bash
set -euxo pipefail

dnf install -y docker jq

systemctl enable --now docker

until systemctl is-active --quiet docker; do
    sleep 2
done

docker pull asdy74/arak-backend:v1

SECRET_ARN="<RDS_SECRET_ARN>"
RDS_HOST="<RDS_ENDPOINT>"

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --query SecretString \
    --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

docker rm -f arak-api 2>/dev/null || true

docker run -d \
    --name arak-api \
    --restart unless-stopped \
    -p 5000:5000 \
    -e "ConnectionStrings__DefaultConnection=Server=${RDS_HOST},1433;Database=ArakDB;User Id=${DB_USER};Password=${DB_PASSWORD};TrustServerCertificate=True" \
    -e "Jwt__Issuer=ArakAPI" \
    -e "Jwt__Audience=ArakDashboard" \
    -e "Jwt__ExpirationHours=24" \
    -e "ASPNETCORE_ENVIRONMENT=Production" \
    asdy74/arak-backend:v1
