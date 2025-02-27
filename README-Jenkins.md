# Jenkins Setup Guide for GameStore (Ubuntu)

## Prerequisites

1. Ubuntu 20.04 or later
2. Jenkins installed
3. Docker and Docker Compose installed (APT version, not snap)

## Installation Steps

1. Remove snap version of Docker (if installed):
   ```bash
   sudo snap remove docker
   ```

2. Install Docker using apt:
   ```bash
   # Remove old versions
   sudo apt-get remove docker docker-engine docker.io containerd runc

   # Install prerequisites
   sudo apt-get update
   sudo apt-get install \
       ca-certificates \
       curl \
       gnupg \
       lsb-release

   # Add Docker's official GPG key
   sudo mkdir -m 0755 -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

   # Add Docker repository
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

   # Install Docker Engine
   sudo apt-get update
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

3. Configure Jenkins user:
   ```bash
   # Stop Jenkins
   sudo systemctl stop jenkins

   # Move Jenkins home to /home directory
   sudo usermod -d /home/jenkins jenkins
   sudo mkdir -p /home/jenkins
   sudo chown -R jenkins:jenkins /home/jenkins

   # Add Jenkins to Docker group
   sudo usermod -aG docker jenkins

   # Restart Jenkins
   sudo systemctl start jenkins
   ```

4. Set proper permissions:
   ```bash
   # Set Docker socket permissions
   sudo chmod 666 /var/run/docker.sock

   # Set workspace permissions
   sudo mkdir -p /home/jenkins/workspace
   sudo chown -R jenkins:jenkins /home/jenkins/workspace
   ```

5. Verify installations:
   ```bash
   # Check Docker
   sudo -u jenkins docker info
   sudo -u jenkins docker-compose version
   
   # Check Jenkins
   sudo systemctl status jenkins
   ```

## Troubleshooting

1. If Docker commands fail:
   ```bash
   # Verify Docker service
   sudo systemctl status docker

   # Restart Docker
   sudo systemctl restart docker

   # Verify Jenkins user in Docker group
   groups jenkins
   ```

2. If workspace issues occur:
   ```bash
   # Reset workspace permissions
   sudo chown -R jenkins:jenkins /home/jenkins/workspace
   sudo chmod -R 755 /home/jenkins/workspace
   ```

3. If Docker socket issues:
   ```bash
   # Reset Docker socket permissions
   sudo chmod 666 /var/run/docker.sock
   ```

For detailed setup instructions and pipeline configuration, refer to the previous sections in this README.
