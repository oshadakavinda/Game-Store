pipeline {
    agent any

    options {
        timeout(time: 1, unit: 'HOURS') // Set a timeout for the pipeline
        retry(3) // Retry the pipeline up to 3 times on failure
    }

    environment {
        COMPOSE_PROJECT_NAME = "gamestore-${BUILD_NUMBER}" // Unique project name for Docker Compose
        DOCKER_BUILDKIT = '1' // Enable Docker BuildKit for faster builds
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs() // Clean the workspace before starting
            }
        }

        stage('Checkout Code') {
            steps {
                checkout scm // Checkout the source code from SCM (e.g., Git)
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'docker-compose build --no-cache' // Build Docker images without cache
            }
        }

        stage('Start Containers') {
            steps {
                sh '''
                    docker-compose down -v || true // Stop and remove any existing containers
                    docker-compose up -d // Start containers in detached mode
                    sleep 30 // Wait for services to initialize
                '''
            }
        }

        stage('Verify Services') {
            steps {
                sh '''
                    docker-compose ps --filter status=running | grep "gamestore" || exit 1 // Check if containers are running
                    curl -f http://localhost:5274/status || exit 1 // Verify API is running
                    curl -f http://localhost:5002 || exit 1 // Verify Frontend is running
                '''
            }
        }
    }

    post {
        always {
            sh '''
                docker-compose down -v || true // Stop and remove containers
                docker system prune -f // Clean up Docker resources
            '''
            cleanWs() // Clean the workspace after the pipeline
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}
