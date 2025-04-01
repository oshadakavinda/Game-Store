# GameStore Infrastructure as Code

This directory contains Terraform configurations for deploying the GameStore application infrastructure on AWS.

## Infrastructure Components

- VPC with public subnets
- ECR repositories for API and Frontend containers
- ECS Cluster for container orchestration
- Application Load Balancer (ALB)
- Security Groups
- IAM roles and policies

## Prerequisites

1. AWS CLI installed and configured
2. Terraform installed (version >= 1.2.0)
3. Docker installed (for building and pushing container images)

## Directory Structure

```
terraform/
├── main.tf           # Main infrastructure configuration
├── variables.tf      # Variable definitions
├── outputs.tf        # Output definitions
├── providers.tf      # Provider configurations
├── environments/     # Environment-specific variables
│   ├── dev.tfvars   # Development environment variables
│   └── prod.tfvars  # Production environment variables
└── README.md        # This file
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Select environment (dev/prod):
```bash
# For development
terraform plan -var-file="environments/dev.tfvars"

# For production
terraform plan -var-file="environments/prod.tfvars"
```

3. Apply the configuration:
```bash
# For development
terraform apply -var-file="environments/dev.tfvars"

# For production
terraform apply -var-file="environments/prod.tfvars"
```

4. Push Docker images to ECR:
```bash
# Login to ECR
aws ecr get-login-password --region $(terraform output -raw aws_region) | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_api_url)

# Build and push API image
docker build -t gamestore-api ./GameStore.Api
docker tag gamestore-api:latest $(terraform output -raw ecr_repository_api_url):latest
docker push $(terraform output -raw ecr_repository_api_url):latest

# Build and push Frontend image
docker build -t gamestore-frontend ./GameStore.Frontend
docker tag gamestore-frontend:latest $(terraform output -raw ecr_repository_frontend_url):latest
docker push $(terraform output -raw ecr_repository_frontend_url):latest
```

## Important Notes

1. The SQLite database file is included in the API container, so no separate RDS instance is needed
2. The ALB routes `/api/*` requests to the API service and all other requests to the Frontend service
3. Health checks are configured for both services
4. The infrastructure is set up in public subnets for simplicity, but can be modified to use private subnets with NAT gateways for production use

## Clean Up

To destroy the infrastructure:
```bash
# For development
terraform destroy -var-file="environments/dev.tfvars"

# For production
terraform destroy -var-file="environments/prod.tfvars"
```

## Security Considerations

1. The SQLite database is containerized with the API service. Consider backing up the database file regularly
2. The ALB is public-facing. Consider implementing WAF rules for production
3. Consider implementing HTTPS with ACM certificates for production
4. Review and adjust the security group rules based on your security requirements
