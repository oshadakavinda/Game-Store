pipeline {
    agent any

    options {
        timeout(time: 1, unit: 'HOURS')
        retry(3)
    }

    environment {
        DOTNET_CLI_HOME = '/var/jenkins/workspace/temp'
        ASPNETCORE_ENVIRONMENT = 'Production'
        COMPOSE_PROJECT_NAME = "gamestore-${BUILD_NUMBER}"
        DOCKER_BUILDKIT = '1'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                script {
                    // Configure Git for better stability
                    sh '''
                        git config --global core.longpaths true
                        git config --global http.postBuffer 524288000
                        git config --global core.compression 9
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
                    sh 'docker info'
                    // Clean up Docker resources
                    sh '''
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
                        sh 'docker-compose build --no-cache'
                    }
                }
            }
        }

        stage('Docker Compose Up') {
            steps {
                script {
                    // Start containers
                    sh 'docker-compose up -d'
                    
                    // Wait for services to be healthy
                    sh 'sleep 45'
                    
                    // Verify services are running
                    sh '''
                        # Check if containers are running
                        docker-compose ps --filter status=running | grep "gamestore" || exit 1
                        
                        # Check API availability
                        curl -f http://localhost:5274/status || exit 1
                        
                        # Check Frontend availability
                        curl -f http://localhost:5002 || exit 1
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                // Stop and remove containers, networks, and volumes
                sh 'docker-compose down -v'
                
                // Clean up Docker resources
                sh '''
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
