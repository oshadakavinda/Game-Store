pipeline {
    agent any

    environment {
        // Environment variables for Docker Compose
        COMPOSE_PROJECT_NAME = 'gamestore' // Unique project name to avoid conflicts
        COMPOSE_FILE = 'docker-compose.yml' // Path to your docker-compose.yml file
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull the code from the Git repository
                checkout scm
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Build Docker images using docker-compose
                    sh 'docker-compose build'
                }
            }
        }

        stage('Start Containers') {
            steps {
                script {
                    // Start the containers in detached mode
                    sh 'docker-compose up -d'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Optionally, run tests inside the containers
                    sh 'docker-compose exec backend dotnet test'
                }
            }
        }

        stage('Verify Services') {
            steps {
                script {
                    // Verify that the services are running
                    sh 'docker compose ps'
                }
            }
        }
    }

    post {
        always {
            // Clean up Docker Compose resources
            script {
                sh 'docker-compose down'
            }
            echo 'Cleaning up...'
        }
        success {
            echo 'Build and deployment successful!'
        }
        failure {
            echo 'Build or deployment failed.'
        }
    }
}