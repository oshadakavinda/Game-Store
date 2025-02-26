pipeline {
    agent any

    environment {
        DOCKER_HOST = 'npipe:////./pipe/docker_engine' // Use Docker Desktop on Windows
        COMPOSE_PROJECT_NAME = 'gamestore'
        COMPOSE_FILE = 'docker-compose.yml'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    sh 'docker compose build'
                }
            }
        }

        stage('Start Containers') {
            steps {
                script {
                    sh 'docker compose up -d'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'docker compose exec backend dotnet test'
                }
            }
        }

        stage('Verify Services') {
            steps {
                script {
                    sh 'docker compose ps'
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'docker compose down'
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
