variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-04b4f1a9cf54c11d0" # Ubuntu AMI
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "devops"
}

variable "frontend_image" {
  description = "Docker image for frontend"
  type        = string
  default     = "oshadakavinda2/game-store-frontend:latest"
}

variable "backend_image" {
  description = "Docker image for backend"
  type        = string
  default     = "oshadakavinda2/game-store-api:latest"
}