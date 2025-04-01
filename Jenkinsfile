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
                        // Stop and remove existing containers
                        sh 'docker-compose down -v || true'
                        
                        // Pull latest images
                        sh 'docker pull oshadakavinda2/game-store-backend:latest'
                        sh 'docker pull oshadakavinda2/game-store-frontend:latest'
                        
                        // Start services
                        sh 'docker-compose up -d'
                        
                        // Show running containers
                        sh 'docker ps'
                        sh 'docker-compose logs'
                    } catch (Exception e) {
                        echo "Error during deployment: ${e.message}"
                        sh 'docker-compose logs'
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
                // Keep the containers running, only cleanup workspace
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