pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-hub'  // Jenkins credentials ID
        DOCKERHUB_USERNAME = 'oshadakavinda2' // Change this to your Docker Hub username
        FRONTEND_IMAGE = 'oshadakavinda2/game-store-frontend'
        API_IMAGE = 'oshadakavinda2/game-store-api'
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
                        userRemoteConfigs: [[
                            url: 'https://github.com/oshadakavinda/Game-Store.git'
                        ]]
                    ])
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    try {
                        // Build Frontend and API images
                        bat "docker build -t ${FRONTEND_IMAGE}:latest GameStore.Frontend/"
                        bat "docker build -t ${API_IMAGE}:latest GameStore.Api/"
                    } catch (Exception e) {
                        echo "Error during Docker build: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Docker build failed")
                    }
                }
            }
        }

        stage('Push Images to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        try {
                            bat "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                            bat "docker push ${FRONTEND_IMAGE}:latest"
                            bat "docker push ${API_IMAGE}:latest"
                        } catch (Exception e) {
                            echo "Error during Docker push: ${e.message}"
                            currentBuild.result = 'FAILURE'
                            error("Docker push failed")
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                cleanWs()
            }
        }
        success {
            echo '✅ Docker images successfully pushed to Docker Hub!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}