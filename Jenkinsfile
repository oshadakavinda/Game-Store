pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage('Deploy Docker Hub Images') {
            steps {
                script {
                    try {
                        // Pull latest images
                        bat 'docker pull oshadakavinda2/game-store-backend:latest'
                        bat 'docker pull oshadakavinda2/game-store-frontend:latest'
                        
                        // Stop any existing containers but keep volumes
                        bat 'docker-compose down || echo "No existing containers"'
                        
                        // Start services
                        bat 'docker-compose up -d'
                        
                        // Show running containers
                        bat 'docker ps'
                    } catch (Exception e) {
                        echo "Error during deployment: ${e.message}"
                        bat 'docker-compose logs'
                        currentBuild.result = 'FAILURE'
                        error("Deployment failed")
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Only cleanup workspace, DO NOT bring down containers
                cleanWs()
            }
        }
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}