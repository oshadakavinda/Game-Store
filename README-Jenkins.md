# Jenkins Setup Guide for GameStore (Windows)

## Prerequisites

1. Windows 10/11
2. Jenkins for Windows installed
3. Docker Desktop for Windows installed and running
4. Git for Windows installed

## Required Jenkins Plugins

- Docker Pipeline Plugin
- Docker Plugin
- Git Plugin
- Pipeline Plugin
- GitHub Plugin (if using GitHub)

## Windows-Specific Setup

1. Install Docker Desktop for Windows:
   - Download from https://www.docker.com/products/docker-desktop
   - Install and enable WSL 2 if prompted
   - Start Docker Desktop
   - Verify Docker is running: `docker --version`

2. Install Jenkins for Windows:
   - Download the Windows installer from https://jenkins.io/download/
   - Run the installer and follow the setup wizard
   - Note the initial admin password location
   - Access Jenkins at http://localhost:8080

3. Configure Jenkins Service Account:
   - Open Services (services.msc)
   - Find Jenkins service
   - Right-click → Properties → Log On tab
   - Select "This account" and use an account with Docker permissions
   - Restart Jenkins service

4. Configure Docker Desktop Settings:
   - Enable "Expose daemon on tcp://localhost:2375 without TLS"
   - In General settings, enable "Use Docker Compose V2"

## Jenkins Configuration Steps

1. Create a new Pipeline job:
   - Open Jenkins at http://localhost:8080
   - Click "New Item"
   - Enter name (e.g., "GameStore-Pipeline")
   - Select "Pipeline"
   - Click "OK"

2. Configure Source Code Management:
   - Select Git
   - Enter your repository URL
   - Configure credentials if required

3. Configure Pipeline:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your repository URL
   - Script Path: Jenkinsfile

## Environment Variables in Jenkins

Configure these system environment variables in Jenkins:
1. Go to Manage Jenkins → System Configuration → System
2. Add the following environment variables:
   - DOCKER_HOST=tcp://localhost:2375
   - COMPOSE_CONVERT_WINDOWS_PATHS=1
   - DOTNET_CLI_HOME=C:\\Jenkins\\workspace\\temp

## Running the Pipeline

1. Verify Prerequisites:
   ```powershell
   # Check Docker
   docker --version
   docker-compose --version
   
   # Check Docker daemon
   docker info
   ```

2. Start the Pipeline:
   - Open the project in Jenkins
   - Click "Build Now"

3. Monitor Build:
   - Click on the build number
   - Click "Console Output" to view progress

## Troubleshooting Windows-Specific Issues

1. Docker Connection Issues:
   - Ensure Docker Desktop is running
   - Verify Docker daemon is exposed (tcp://localhost:2375)
   - Check Jenkins service has proper permissions

2. Path Issues:
   - Ensure COMPOSE_CONVERT_WINDOWS_PATHS=1 is set
   - Use double backslashes in Windows paths
   - Check workspace permissions

3. Permission Issues:
   - Run Jenkins service as administrator
   - Add Jenkins user to Docker users group
   - Verify folder permissions

4. Docker Desktop Issues:
   - Restart Docker Desktop
   - Check WSL 2 integration
   - Verify resource allocation

## Best Practices for Windows

1. File System:
   - Use short paths when possible
   - Avoid spaces in paths
   - Use Windows-style paths in configurations

2. Docker:
   - Regular cleanup of Windows containers
   - Monitor Docker Desktop resources
   - Use Windows containers when needed

3. Security:
   - Secure Docker daemon
   - Use Windows credential manager
   - Regular Windows updates

## Maintenance

1. Regular Tasks:
   - Clean Jenkins workspace
   - Prune Docker resources
   - Update Docker Desktop
   - Update Jenkins plugins

2. Monitoring:
   - Watch Docker Desktop resources
   - Monitor disk space
   - Check Jenkins logs

## Support

For issues with the Windows Jenkins pipeline:
1. Check Jenkins console output
2. Review Docker Desktop logs
3. Verify Windows Event Viewer
4. Check network connectivity
5. Verify Docker Desktop status

## Additional Windows Tools

1. Recommended Tools:
   - Windows Terminal
   - PowerShell 7+
   - WSL 2
   - Visual Studio Code

2. Debugging Tools:
   - Docker Desktop Dashboard
   - Windows Resource Monitor
   - Process Explorer
