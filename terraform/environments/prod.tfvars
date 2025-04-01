environment     = "prod"
aws_region      = "us-east-1"
vpc_cidr        = "10.1.0.0/16"  # Different CIDR for prod
container_port  = 80
container_cpu   = 512            # More CPU for prod
container_memory = 1024          # More memory for prod
desired_count   = 2              # Higher count for prod redundancy
health_check_path = "/"
