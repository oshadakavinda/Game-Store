pipeline {
    agent any

    environment {
         DOCKER_HOST = "tcp://172.18.0.4:2375"
        BACKEND_IMAGE = 'game-store-backend'
        FRONTEND_IMAGE = 'game-store-frontend'
        BACKEND_CONTAINER = 'gamestore-backend-container'
        FRONTEND_CONTAINER = 'gamestore-frontend-container'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend Image') {
            steps {
                script {
                    sh 'docker build -t $BACKEND_IMAGE GameStore.Api'
                }
            }
        }

        stage('Build Frontend Image') {
            steps {
                script {
                    sh 'docker build -t $FRONTEND_IMAGE GameStore.Frontend'
                }
            }
        }

        stage('Run Backend Container') {
            steps {
                script {
                    sh 'docker run -d --name $BACKEND_CONTAINER -p 5000:5000 $BACKEND_IMAGE'
                }
            }
        }

        stage('Run Frontend Container') {
            steps {
                script {
                    sh 'docker run -d --name $FRONTEND_CONTAINER -p 3000:3000 $FRONTEND_IMAGE'
                }
            }
        }

        stage('Run Backend Tests') {
            steps {
                script {
                    sh 'docker exec $BACKEND_CONTAINER dotnet test'
                }
            }
        }

        stage('Verify Containers') {
            steps {
                script {
                    sh 'docker ps | grep $BACKEND_CONTAINER'
                    sh 'docker ps | grep $FRONTEND_CONTAINER'
                }
            }
        }
    }

    post {
        always {
            script {
                // Stop and remove backend container
                sh 'docker stop $BACKEND_CONTAINER || true'
                sh 'docker rm $BACKEND_CONTAINER || true'

                // Stop and remove frontend container
                sh 'docker stop $FRONTEND_CONTAINER || true'
                sh 'docker rm $FRONTEND_CONTAINER || true'

                // Remove images
                sh 'docker rmi $BACKEND_IMAGE || true'
                sh 'docker rmi $FRONTEND_IMAGE || true'
            }
            echo 'Cleaned up Docker resources.'
        }
        success {
            echo 'Build and deployment successful!'
        }
        failure {
            echo 'Build or deployment failed.'
        }
    }
}
