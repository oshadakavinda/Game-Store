pipeline {
    agent {
        docker {
            image 'mcr.microsoft.com/dotnet/sdk:8.0'
            label 'docker-dotnet'
        }
    }

    environment {
        DOTNET_SDK_VERSION = '8.0'
        SOLUTION_FILE = 'GameStore.sln'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Restore Dependencies') {
            steps {
                sh 'dotnet restore ${SOLUTION_FILE}'
            }
        }

        stage('Build API') {
            steps {
                dir('GameStore.Api') {
                    sh 'dotnet build --configuration Release --no-restore'
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('GameStore.Frontend') {
                    sh 'dotnet build --configuration Release --no-restore'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'dotnet test --no-restore --verbosity normal'
            }
        }

        stage('Publish API') {
            steps {
                dir('GameStore.Api') {
                    sh 'dotnet publish --configuration Release --output publish/api'
                }
            }
        }

        stage('Publish Frontend') {
            steps {
                dir('GameStore.Frontend') {
                    sh 'dotnet publish --configuration Release --output publish/frontend'
                }
            }
        }
    }

    post {
        always {
            node('any') {
                cleanWs()
            }
        }
        success {
            echo 'Build and deployment successful!'
        }
        failure {
            echo 'Build or deployment failed!'
        }
    }
}
