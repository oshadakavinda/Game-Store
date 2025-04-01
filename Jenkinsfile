pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub')  // Use Jenkins stored credentials
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        skipDefaultCheckout(true)
    }

    stages {
        stage('Optimized Checkout') {
            steps {
                script {
                    cleanWs()
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/master']],
                        extensions: [
                            [$class: 'CloneOption', depth: 1, noTags: true, shallow: true, timeout: 10],
                            [$class: 'CleanBeforeCheckout'],
                            [$class: 'SparseCheckoutPaths', 
                             sparseCheckoutPaths: [
                                [$class: 'SparseCheckoutPath', path: 'GameStore.Api/'],
                                [$class: 'SparseCheckoutPath', path: 'GameStore.Frontend/'],
                                [$class: 'SparseCheckoutPath', path: 'docker-compose.yml'],
                                [$class: 'SparseCheckoutPath', path: '.gitignore']
                             ]]
                        ],
                        userRemoteConfigs: [[url: 'https://github.com/oshadakavinda/Game-Store.git']]
                    ])
                }
            }
        }

        stage('Build and Start Services') {
            steps {
                script {
                    try {
                        // Stop running containers if any
                        sh 'docker-compose down'

                        // Log in to Docker Hub
                        sh 'echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin'

                        // Build and start services
                        sh 'docker-compose build --no-cache'
                        sh 'docker-compose up -d'

                        // Show running containers and logs
                        sh '''
                            echo "Running Containers:"
                            docker ps

                            echo "Container Logs:"
                            docker-compose logs
                        '''
                    } catch (Exception e) {
                        echo "Error during build and start: ${e.message}"
                        sh 'docker-compose logs'
                        currentBuild.result = 'FAILURE'
                        error("Build and start services failed")
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    try {
                        // Tag and push backend image
                        sh 'docker tag game-store-backend oshadakavinda2/game-store-backend:latest'
                        sh 'docker push oshadakavinda2/game-store-backend:latest'

                        // Tag and push frontend image
                        sh 'docker tag game-store-frontend oshadakavinda2/game-store-frontend:latest'
                        sh 'docker push oshadakavinda2/game-store-frontend:latest'
                    } catch (Exception e) {
                        echo "Error during Docker Hub push: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Failed to push images to Docker Hub")
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    sh 'docker-compose logs'
                    cleanWs()
                } catch (Exception e) {
                    echo "Warning during cleanup: ${e.message}"
                }
            }
        }
        success {
            echo 'Pipeline completed successfully! Application is running on AWS.'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
