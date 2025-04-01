environment     = "dev"
aws_region      = "us-east-1"
vpc_cidr        = "10.0.0.0/16"
container_port  = 80
container_cpu   = 256
container_memory = 512
desired_count   = 1  # Lower count for dev environment
health_check_path = "/"
