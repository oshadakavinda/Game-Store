pipeline {
    agent any

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
                            [$class: 'CloneOption',
                             depth: 1,
                             noTags: true,
                             shallow: true,
                             timeout: 10],
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

        stage('Build and Start Services') {
            steps {
                script {
                    try {
                        bat 'docker-compose down -v'



                        bat 'docker-compose build --no-cache'
                        bat 'docker-compose up -d'

                        // Show running containers and logs
                        bat '''
                            echo "Running Containers:"
                            docker ps
                            
                            echo "Container Logs:"
                            docker-compose logs
                        '''
                    } catch (Exception e) {
                        echo "Error during build and start: ${e.message}"
                        bat 'docker-compose logs'
                        currentBuild.result = 'FAILURE'
                        error("Build and start services failed")
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                try {

                    bat 'docker-compose logs'
                    bat 'docker-compose down -v'

                    cleanWs()
                } catch (Exception e) {
                    echo "Warning during cleanup: ${e.message}"
                }
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