terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Ensures compatibility with recent AWS provider versions
    }
  }

  required_version = ">= 1.0.0" # Ensures Terraform version is compatible
}

provider "aws" {
  region = "us-east-1" # Specify the AWS region
  # No hardcoded credentials - will be provided by environment variables
}

# Step 1: Create Security Group in Default VPC
resource "aws_security_group" "devops_sg" {
  name        = "game-store-security-group"
  description = "Allow SSH, HTTP, HTTPS, and application-specific ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (Not secure for production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS access from anywhere
  }

  # Game Store Backend Port
  ingress {
    from_port   = 5274
    to_port     = 5274
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow access to backend port
  }

  # Game Store Frontend Port
  ingress {
    from_port   = 5003
    to_port     = 5003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow access to frontend port
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "game-store-security-group"
  }
}

# Step 2: Create EC2 Instance with Security Group
resource "aws_instance" "game_store_instance" {
  ami           = "ami-04b4f1a9cf54c11d0" # Ubuntu AMI ID
  instance_type = "t2.micro"              # Free tier eligible instance type
  key_name      = "devops"                # Your SSH key pair name

  # Attach Security Group by ID
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  # Install Docker, Docker Compose and deploy the game store application
  user_data = <<-EOF
              #!/bin/bash
              # Update and install dependencies
              sudo apt-get update -y
              sudo apt-get install -y docker.io curl
              
              # Start and enable Docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              
              # Install Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              
              # Create docker-compose.yml
              cat > /home/ubuntu/docker-compose.yml <<'DOCKERCOMPOSE'
              version: '3'
              services:
                backend:
                  image: oshadakavinda2/game-store-api:latest
                  ports:
                    - "5274:5274"
                  environment:
                    - ASPNETCORE_URLS=http://0.0.0.0:5274
                  volumes:
                    - sqlite_data:/app/Data
                  restart: always
              
                frontend:
                  image: oshadakavinda2/game-store-frontend:latest
                  ports:
                    - "5003:8080"
                  depends_on:
                    - backend
                  restart: always
              
              volumes:
                sqlite_data:
              DOCKERCOMPOSE
              
              # Fix permissions
              sudo chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml
              
              # Pull the images
              sudo docker pull oshadakavinda2/game-store-api:latest
              sudo docker pull oshadakavinda2/game-store-frontend:latest
              
              # Deploy the application using Docker Compose
              cd /home/ubuntu
              sudo docker-compose up -d
              
              # Create a deployment log for troubleshooting
              echo "Deployment completed at $(date)" > /home/ubuntu/deployment.log
              sudo docker ps >> /home/ubuntu/deployment.log
              EOF

  # Add EBS volume for persistent data
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "GameStoreInstance"
  }
}

# Step 3: Create an Elastic IP for the instance
resource "aws_eip" "game_store_eip" {
  instance = aws_instance.game_store_instance.id
  domain   = "vpc"
  
  tags = {
    Name = "GameStoreEIP"
  }
}

output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.game_store_instance.id
}

output "instance_public_ip" {
  description = "The public IP of the created EC2 instance"
  value       = aws_eip.game_store_eip.public_ip
}

output "application_urls" {
  description = "URLs to access the application"
  value = {
    frontend = "http://${aws_eip.game_store_eip.public_ip}:5003"
    backend  = "http://${aws_eip.game_store_eip.public_ip}:5274"
  }
}