pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-creds') // Verify this credential exists in Jenkins
        BACKEND_IMAGE = 'oshadakavinda2/game-store-backend:latest'
        FRONTEND_IMAGE = 'oshadakavinda2/game-store-frontend:latest'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    extensions: [
                        [$class: 'SparseCheckoutPaths', 
                         sparseCheckoutPaths: [[path: 'docker-compose.yml']]
                        ],
                        [$class: 'RelativeTargetDirectory', relativeTargetDir: 'gamestore']
                    ],
                    userRemoteConfigs: [[url: 'https://github.com/oshadakavinda/Game-Store.git']]
                ])
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        bat """
                            echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        """
                    }
                }
            }
        }

        stage('Pull Images') {
            steps {
                dir('gamestore') {
                    bat """
                        docker pull %BACKEND_IMAGE%
                        docker pull %FRONTEND_IMAGE%
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                dir('gamestore') {
                    bat """
                        docker-compose down --remove-orphans || exit 0
                        docker-compose up -d
                        timeout /t 15 /nobreak > NUL
                        docker-compose ps
                    """
                }
            }
        }

        stage('Verify') {
            steps {
                dir('gamestore') {
                    bat """
                        curl -I http://localhost:5274/api/games || echo Backend check failed
                        curl -I http://localhost:5002 || echo Frontend check failed
                    """
                }
            }
        }
    }

    post {
        always {
            dir('gamestore') {
                bat """
                    docker-compose logs --tail=50
                    docker logout
                """
                cleanWs()
            }
        }
        success {
            echo '🚀 Deployment Successful!'
            echo 'Frontend: http://localhost:5002'
            echo 'Backend: http://localhost:5274'
        }
        failure {
            echo ' Deployment Failed - Check logs above'
        }
    }
}