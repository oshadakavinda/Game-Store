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
                        // Only stop containers if they're already running
                        bat 'docker-compose down'
                        
                        // Build and start services
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
                    // Only show logs, don't stop containers
                    bat 'docker-compose logs'
                    
                    // Clean workspace but keep containers running
                    cleanWs()
                } catch (Exception e) {
                    echo "Warning during cleanup: ${e.message}"
                }
            }
        }
        success {
            echo 'Pipeline completed successfully! Application is running at:'
            echo 'Frontend: http://localhost:5002'
            echo 'Backend: http://localhost:5274'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
