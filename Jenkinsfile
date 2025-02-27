pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Start Services') {
            steps {
                script {
                    // Build and start all services using docker-compose
                    sh 'docker-compose build'
                    sh 'docker-compose up -d'
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    // Wait for services to be healthy
                    sh '''
                        # Wait for backend
                        timeout=300
                        while ! curl -s http://localhost:5274 > /dev/null; do
                            sleep 5
                            timeout=$((timeout - 5))
                            if [ $timeout -le 0 ]; then
                                echo "Backend service failed to start"
                                exit 1
                            fi
                        done

                        # Wait for frontend
                        timeout=300
                        while ! curl -s http://localhost:5002 > /dev/null; do
                            sleep 5
                            timeout=$((timeout - 5))
                            if [ $timeout -le 0 ]; then
                                echo "Frontend service failed to start"
                                exit 1
                            fi
                        done
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up containers and volumes
                sh '''
                    docker-compose down -v
                    docker system prune -f
                '''
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
