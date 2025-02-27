pipeline {
    agent any

    environment {
        DOTNET_CLI_HOME = 'C:\\Jenkins\\workspace\\temp'
        ASPNETCORE_ENVIRONMENT = 'Production'
        COMPOSE_PROJECT_NAME = "gamestore-${BUILD_NUMBER}"
        DOCKER_BUILDKIT = '1'
        // Windows-specific path handling
        COMPOSE_CONVERT_WINDOWS_PATHS = 1
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Compose Build') {
            steps {
                script {
                    // Windows command for docker-compose build
                    bat 'docker-compose build --no-cache'
                }
            }
        }

        stage('Docker Compose Up') {
            steps {
                script {
                    // Start the containers in detached mode
                    bat 'docker-compose up -d'
                    
                    // Wait for services to be healthy (Windows sleep command)
                    bat 'timeout /t 45 /nobreak'
                    
                    // Verify services are running (Windows commands)
                    bat '''
                        @echo off
                        
                        REM Check if containers are running
                        docker-compose ps --filter status=running | findstr "gamestore" || exit /b 1
                        
                        REM Check API availability
                        curl -f http://localhost:5274/status || exit /b 1
                        
                        REM Check Frontend availability
                        curl -f http://localhost:5002 || exit /b 1
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                // Stop and remove containers, networks, and volumes
                bat 'docker-compose down -v'
                
                // Clean up any dangling images and volumes (Windows commands)
                bat '''
                    docker image prune -f
                    docker volume prune -f
                '''
                
                // Clean workspace
                cleanWs()
            }
        }
        success {
            echo 'Docker Compose deployment successful!'
        }
        failure {
            echo 'Docker Compose deployment failed!'
        }
    }
}
