# Jenkins Setup Guide for GameStore

## Prerequisites

1. Jenkins server installed and running
2. .NET SDK 8.0 installed on Jenkins agent
3. Git installed on Jenkins agent

## Required Jenkins Plugins

- .NET SDK Plugin
- Git Plugin
- Pipeline Plugin
- GitHub Plugin (if using GitHub)

## Jenkins Configuration Steps

1. Create a new Pipeline job in Jenkins:
   - Click "New Item"
   - Enter a name (e.g., "GameStore-Pipeline")
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

## Environment Setup

1. Install .NET SDK 8.0 on Jenkins agent:
   ```bash
   wget https://download.visualstudio.microsoft.com/download/pr/xxx/dotnet-sdk-8.0.xxx-linux-x64.tar.gz
   mkdir -p $HOME/dotnet && tar zxf dotnet-sdk-8.0.xxx-linux-x64.tar.gz -C $HOME/dotnet
   export DOTNET_ROOT=$HOME/dotnet
   export PATH=$PATH:$HOME/dotnet
   ```

2. Verify installation:
   ```bash
   dotnet --version
   ```

## Pipeline Stages

The pipeline includes the following stages:

1. **Checkout**: 
   - Clones the repository

2. **Restore Dependencies**: 
   - Restores NuGet packages for both API and Frontend projects

3. **Build API**: 
   - Builds the GameStore.Api project in Release configuration

4. **Build Frontend**: 
   - Builds the GameStore.Frontend project in Release configuration

5. **Test**: 
   - Runs unit tests for both projects

6. **Publish**: 
   - Creates deployment artifacts for both API and Frontend
   - Output locations:
     - API: publish/api
     - Frontend: publish/frontend

## Environment Variables

Configure the following environment variables in Jenkins:

1. Required Variables:
   - DOTNET_SDK_VERSION: 8.0
   - SOLUTION_FILE: GameStore.sln

2. Optional Variables (based on environment):
   - DATABASE_CONNECTION_STRING
   - API_KEY
   - DEPLOYMENT_TARGET

## Troubleshooting

1. If build fails with dotnet command not found:
   - Verify .NET SDK installation
   - Check PATH environment variable

2. If restore fails:
   - Check NuGet configuration
   - Verify network connectivity to NuGet repositories

3. If tests fail:
   - Check test logs in Jenkins console output
   - Verify test environment configuration

## Best Practices

1. Source Control:
   - Always commit Jenkinsfile to source control
   - Keep sensitive data out of the Jenkinsfile

2. Security:
   - Use Jenkins credentials store for sensitive data
   - Regularly update Jenkins and plugins
   - Implement proper access controls

3. Maintenance:
   - Regularly clean workspace
   - Monitor build times
   - Set up build notifications

## Additional Recommendations

1. Quality Gates:
   - Add code coverage reporting
   - Implement static code analysis
   - Set up security scanning

2. Deployment:
   - Implement blue-green deployment
   - Set up automated rollback procedures
   - Configure deployment notifications

3. Monitoring:
   - Set up build monitoring
   - Configure build time alerts
   - Implement log aggregation

## Support

For issues with the Jenkins pipeline:
1. Check Jenkins console output
2. Review system logs
3. Verify environment configurations
4. Check network connectivity
