pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    environment {
        BACKEND_IMAGE = 'oshadakavinda2/game-store-backend'
        FRONTEND_IMAGE = 'oshadakavinda2/game-store-frontend'
    }

    stages {
        stage('Pull Latest Docker Hub Images') {
            steps {
                script {
                    try {
                        echo 'Pulling latest Docker images...'
                        sh "docker pull ${BACKEND_IMAGE}:latest"
                        sh "docker pull ${FRONTEND_IMAGE}:latest"
                    } catch (Exception e) {
                        echo "Error during image pulling: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Image pull failed")
                    }
                }
            }
        }

        stage('Deploy Docker Hub Images') {
            steps {
                script {
                    try {
                        echo 'Stopping and removing existing containers...'
                        sh 'docker-compose down -v || true'
                        
                        echo 'Starting services with new images...'
                        sh 'docker-compose up -d'

                        echo 'Showing running containers...'
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
                cleanWs()  // Clean workspace but keep containers running
            }
        }
        success {
            echo '✅ Deployment completed successfully!'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}
