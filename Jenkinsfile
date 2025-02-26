pipeline {
    agent any

    environment {
        DOTNET_CLI_HOME = '/tmp' // Required for .NET Core in Jenkins environment
        ASPNETCORE_ENVIRONMENT = 'Production'
        IMAGE_NAME = 'gamestore-api'
        DOCKER_IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/oshadakavinda/Game-Store',
                        credentialsId: 'your-credentials-id' // Add credentials if the repo is private
                    ]],
                    extensions: [[
                        $class: 'CloneOption',
                        timeout: 30, // Increase timeout
                        shallow: true, // Enable shallow clone
                        depth: 1 // Clone only the latest commit
                    ]]
                ])
            }
        }

        stage('Restore Dependencies') {
            steps {
                script {
                    sh 'dotnet restore'
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    sh 'dotnet build -c Release'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    sh 'dotnet test'
                }
            }
        }

        stage('Publish') {
            steps {
                script {
                    sh 'dotnet publish -c Release -o ./publish'
                }
            }
        }

        stage('Docker Build & Push (Optional)') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME:$DOCKER_IMAGE_TAG .'
                    // Optionally, push to Docker registry
                    // sh 'docker push $IMAGE_NAME:$DOCKER_IMAGE_TAG'
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                script {
                    // You can deploy your app via Docker or directly to a server
                    // If you're deploying with Docker:
                    // sh 'docker run -d -p 5274:5274 $IMAGE_NAME:$DOCKER_IMAGE_TAG'
                    
                    // If you're not using Docker, you can deploy directly to the server:
                    // sh 'scp -r ./publish user@your-server:/path/to/deployment/folder'
                    // sh 'ssh user@your-server "systemctl restart gamestore-api"'
                }
            }
        }
    }

    post {
        always {
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