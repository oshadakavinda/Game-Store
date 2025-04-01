pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = credentials('docker-hub-user')  // Jenkins username/password credential
        DOCKER_HUB_PASS = credentials('docker-hub-pass')  // Separate credential for password if needed
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
                        [$class: 'RelativeTargetDirectory', relativeTargetDir: 'gamestore']
                    ],
                    userRemoteConfigs: [[url: 'https://github.com/oshadakavinda/Game-Store.git']]
                ])
                dir('gamestore') {
                    bat 'dir'  // Verify contents
                }
            }
        }

        stage('Docker Login') {
            steps {
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
                        docker-compose down --remove-orphans
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
            echo 'Deployment successful!'
            echo 'Frontend: http://localhost:5002'
            echo 'Backend: http://localhost:5274'
        }
        failure {
            echo 'Deployment failed - check logs above'
        }
    }
}