pipeline {
    agent any

    environment {
    DOCKER_HOST = 'npipe:////./pipe/docker_engine'
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
                    sh 'docker compose exec backend dotnet test || exit 1'  // Ensure non-zero exit code if tests fail
                }
            }
        }

        stage('Verify Services') {
            steps {
                script {
                    sh 'docker compose ps'  // Verifies that services are up
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'docker compose down'  // Cleanup after pipeline run
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
