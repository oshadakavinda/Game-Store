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

1. Install Git for Windows:
   - Download from https://git-scm.com/download/win
   - During installation:
     - Select "Use Git from the Windows Command Prompt"
     - Select "Checkout as-is, commit as-is" for line endings
     - Enable Git Credential Manager

2. Configure Git in Jenkins:
   - Go to Manage Jenkins → Configure System
   - Find Git section
   - Set "Path to Git executable" to: `C:\Program Files\Git\bin\git.exe`
   - Save configuration

3. Configure Git Global Settings:
   ```batch
   git config --system core.longpaths true
   git config --system http.sslverify false
   git config --system http.postBuffer 524288000
   ```

4. Install Docker Desktop for Windows:
   - Download from https://www.docker.com/products/docker-desktop
   - Install and enable WSL 2 if prompted
   - Start Docker Desktop
   - Verify Docker is running: `docker --version`

5. Configure Jenkins Service:
   - Open Services (services.msc)
   - Find Jenkins service
   - Right-click → Properties → Log On tab
   - Select "This account" and use an account with:
     - Docker permissions
     - Git access permissions
     - Admin rights
   - Restart Jenkins service

## Jenkins Pipeline Setup

1. Create new Pipeline job:
   - Open Jenkins at http://localhost:8080
   - Click "New Item"
   - Enter name (e.g., "GameStore-Pipeline")
   - Select "Pipeline"
   - Click "OK"

2. Configure Source Code Management:
   - Select Git
   - Enter your repository URL
   - Configure credentials if required
   - Additional Git settings:
     - Timeout (minutes): 10
     - Set shallow clone depth: 1
     - Check "Clean before checkout"

3. Configure Pipeline:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your repository URL
   - Script Path: Jenkinsfile
   - Additional Behaviors:
     - Add "Clean before checkout"
     - Add "Prune stale remote-tracking branches"

## Troubleshooting Git Issues

1. If "git fetch" fails:
   ```batch
   # Clear Git cache
   cd C:\ProgramData\Jenkins\.jenkins\workspace
   git clean -fdx
   git reset --hard
   
   # Increase Git buffer size
   git config --system http.postBuffer 524288000
   git config --system core.compression 9
   
   # Disable SSL verification (if needed)
   git config --system http.sslVerify false
   ```

2. Network Issues:
   - Check proxy settings
   - Try with SSL verification disabled
   - Increase timeout values
   - Use shallow cloning

3. Workspace Issues:
   - Clean workspace before build
   - Use shorter paths
   - Enable long path support

## Environment Variables

Configure these system environment variables in Jenkins:
1. Go to Manage Jenkins → System Configuration → System
2. Add the following environment variables:
   ```
   DOCKER_HOST=tcp://localhost:2375
   COMPOSE_CONVERT_WINDOWS_PATHS=1
   GIT_SSL_NO_VERIFY=true
   DOTNET_CLI_HOME=C:\\Jenkins\\workspace\\temp
   ```

## Running the Pipeline

1. Verify Prerequisites:
   ```batch
   git --version
   docker --version
   docker-compose --version
   ```

2. Start the Pipeline:
   - Open the project in Jenkins
   - Click "Build Now"
   - Monitor Console Output

## Best Practices for Windows

1. Git:
   - Use shallow clones
   - Enable long paths
   - Configure appropriate timeouts
   - Clean workspace regularly

2. Docker:
   - Regular cleanup of Windows containers
   - Monitor Docker Desktop resources
   - Use Windows containers when needed

3. Jenkins:
   - Run as administrator
   - Use short workspace paths
   - Regular workspace cleanup

## Support

For Git connectivity issues:
1. Check network connectivity
2. Verify Git credentials
3. Clear Git cache
4. Check workspace permissions
5. Review Git configuration
6. Monitor resource usage

For additional assistance:
1. Check Jenkins logs: `C:\ProgramData\Jenkins\.jenkins\logs`
2. Review Git error messages
3. Verify system requirements
4. Check network stability
