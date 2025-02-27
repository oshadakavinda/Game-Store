# Jenkins Setup Guide for GameStore (Ubuntu)

## Prerequisites

1. Ubuntu 20.04 or later
2. Jenkins installed
3. Docker and Docker Compose installed
4. Git installed

## Installation Steps

1. Install Jenkins:
   ```bash
   # Add Jenkins repository
   curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
     /usr/share/keyrings/jenkins-keyring.asc > /dev/null
   echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
     https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
     /etc/apt/sources.list.d/jenkins.list > /dev/null

   # Update and install Jenkins
   sudo apt-get update
   sudo apt-get install jenkins
   ```

2. Install Docker:
   ```bash
   # Install Docker
   sudo apt-get update
   sudo apt-get install \
       ca-certificates \
       curl \
       gnupg \
       lsb-release

   # Add Docker's official GPG key
   sudo mkdir -m 0755 -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

   # Set up repository
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

   # Install Docker Engine
   sudo apt-get update
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

3. Configure Permissions:
   ```bash
   # Add Jenkins user to docker group
   sudo usermod -aG docker jenkins

   # Restart Jenkins
   sudo systemctl restart jenkins
   ```

## Required Jenkins Plugins

Install these plugins through Jenkins Plugin Manager:
- Docker Pipeline
- Docker
- Git
- Pipeline
- GitHub (if using GitHub)

## Jenkins Configuration

1. Create Pipeline Job:
   - Navigate to Jenkins dashboard
   - Click "New Item"
   - Enter name (e.g., "GameStore-Pipeline")
   - Select "Pipeline"
   - Click "OK"

2. Configure Source Code Management:
   - Select Git
   - Enter repository URL
   - Configure credentials if required
   - Branch Specifier: */master (or your main branch)

3. Configure Pipeline:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your repository URL
   - Script Path: Jenkinsfile

## Environment Setup

1. Create Required Directories:
   ```bash
   sudo mkdir -p /var/jenkins/workspace/temp
   sudo chown -R jenkins:jenkins /var/jenkins
   ```

2. Verify Installations:
   ```bash
   # Check Docker
   docker --version
   docker-compose --version
   
   # Check Jenkins
   systemctl status jenkins
   
   # Check Git
   git --version
   ```

## Troubleshooting

1. Permission Issues:
   ```bash
   # Fix Docker permissions
   sudo chmod 666 /var/run/docker.sock
   
   # Fix workspace permissions
   sudo chown -R jenkins:jenkins /var/jenkins/workspace
   ```

2. Docker Issues:
   ```bash
   # Restart Docker
   sudo systemctl restart docker
   
   # Check Docker status
   sudo systemctl status docker
   
   # View Docker logs
   sudo journalctl -fu docker
   ```

3. Jenkins Issues:
   ```bash
   # View Jenkins logs
   sudo journalctl -fu jenkins
   
   # Restart Jenkins
   sudo systemctl restart jenkins
   ```

## Best Practices

1. Security:
   - Use Jenkins credentials store
   - Regularly update system packages
   - Keep Docker images updated
   - Use secure registries

2. Maintenance:
   - Regular backup of Jenkins configuration
   - Clean up old builds
   - Monitor disk space
   - Regular Docker cleanup

3. Performance:
   - Configure proper resource limits
   - Regular cleanup of Docker resources
   - Monitor system resources

## Monitoring

1. System Monitoring:
   ```bash
   # Monitor system resources
   htop
   
   # Monitor Docker
   docker stats
   
   # Check disk space
   df -h
   ```

2. Log Monitoring:
   ```bash
   # Jenkins logs
   tail -f /var/log/jenkins/jenkins.log
   
   # Docker logs
   journalctl -fu docker
   ```

## Support

For issues:
1. Check application logs:
   ```bash
   # Jenkins logs
   sudo tail -f /var/log/jenkins/jenkins.log
   
   # Docker logs
   docker logs <container-id>
   ```

2. System logs:
   ```bash
   # System logs
   sudo journalctl -xe
   ```

3. Check permissions:
   ```bash
   # List permissions
   ls -la /var/run/docker.sock
   ls -la /var/jenkins/workspace
   ```

4. Verify services:
   ```bash
   # Check service status
   sudo systemctl status jenkins
   sudo systemctl status docker
