pipeline {
    agent any

    options {
        // Add timeout and retry options for better stability
        timeout(time: 1, unit: 'HOURS')
        retry(3)
        // Clean workspace before build
        cleanWs()
    }

    environment {
        DOTNET_CLI_HOME = 'C:\\Jenkins\\workspace\\temp'
        ASPNETCORE_ENVIRONMENT = 'Production'
        COMPOSE_PROJECT_NAME = "gamestore-${BUILD_NUMBER}"
        DOCKER_BUILDKIT = '1'
        COMPOSE_CONVERT_WINDOWS_PATHS = 1
        // Git specific configurations
        GIT_SSL_NO_VERIFY = 'true'
        GIT_TIMEOUT = '30m'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Configure Git for better stability
                    bat '''
                        git config --system core.longpaths true
                        git config --system http.sslverify false
                        git config --system http.postBuffer 524288000
                        git config --system core.compression 9
                    '''
                    
                    // Perform checkout with retry
                    retry(3) {
                        checkout scm
                    }
                }
            }
        }

        stage('Prepare Environment') {
            steps {
                script {
                    // Verify Docker is running
                    bat 'docker info'
                    // Clean up Docker resources
                    bat '''
                        docker system prune -f
                        docker volume prune -f
                    '''
                }
            }
        }

        stage('Docker Compose Build') {
            steps {
                script {
                    // Build with retry and no cache
                    retry(2) {
                        bat 'docker-compose build --no-cache'
                    }
                }
            }
        }

        stage('Docker Compose Up') {
            steps {
                script {
                    // Start containers
                    bat 'docker-compose up -d'
                    
                    // Wait for services to be healthy
                    bat 'timeout /t 45 /nobreak'
                    
                    // Verify services are running
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
                
                // Clean up Docker resources
                bat '''
                    docker image prune -f
                    docker volume prune -f
                    docker system prune -f
                '''
                
                // Clean workspace
                cleanWs()
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
        unstable {
            echo 'Pipeline is unstable. Check test results and logs.'
        }
    }
}
