pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-creds')  // Jenkins stored credentials
        AWS_EC2_IP = credentials('aws-ec2-ip')
        BACKEND_IMAGE = 'oshadakavinda2/game-store-backend:latest'
        FRONTEND_IMAGE = 'oshadakavinda2/game-store-frontend:latest'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Prepare Environment') {
            steps {
                cleanWs()
                // Minimal checkout just for docker-compose.yml
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    extensions: [
                        [$class: 'SparseCheckoutPaths', 
                         sparseCheckoutPaths: [[path: 'docker-compose.yml']]
                        ],
                        [$class: 'CloneOption', depth: 1, noTags: true, shallow: true]
                    ],
                    userRemoteConfigs: [[url: 'https://github.com/oshadakavinda/Game-Store.git']]
                ])
            }
        }

        stage('Docker Hub Login') {
            steps {
                script {
                    sh """
                        echo \$DOCKER_HUB_CREDENTIALS_PSW | docker login \
                            -u \$DOCKER_HUB_CREDENTIALS_USR \
                            --password-stdin
                    """
                }
            }
        }

        stage('Pull Images') {
            steps {
                script {
                    try {
                        sh """
                            docker pull ${BACKEND_IMAGE}
                            docker pull ${FRONTEND_IMAGE}
                        """
                    } catch (Exception e) {
                        error "Failed to pull Docker images: ${e.message}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                        # Stop and remove old containers
                        docker-compose down --remove-orphans || true
                        
                        # Start services using pulled images
                        docker-compose up -d
                        
                        # Verify deployment
                        echo "Waiting for services to initialize..."
                        sleep 15
                        docker-compose ps
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    sh """
                        echo "Testing Backend:"
                        curl -I http://localhost:5274/api/games || true
                        
                        echo "Testing Frontend:"
                        curl -I http://localhost:5002 || true
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'docker-compose logs --tail=100'
                cleanWs()
                sh 'docker logout'  // Clean Docker Hub session
            }
        }
        success {
            echo """
            🚀 Deployment Successful!
            Frontend: http://${AWS_EC2_IP_PSW}:5002
            Backend: http://${AWS_EC2_IP_PSW}:5274
            """
        }
        failure {
            echo ' Deployment Failed - Check logs above'
        }
    }
}