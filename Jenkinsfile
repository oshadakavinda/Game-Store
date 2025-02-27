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
                    // Clean workspace before checkout
                    cleanWs()
                    
                    // Shallow clone with specific configurations
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/master']],
                        extensions: [
                            // Shallow clone with depth 1
                            [$class: 'CloneOption',
                             depth: 1,
                             noTags: true,
                             shallow: true,
                             timeout: 10],
                            // Clean before checkout
                            [$class: 'CleanBeforeCheckout'],
                            // Sparse checkout to get only necessary files
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

                    // Verify checkout
                    bat '''
                        echo "Checking cloned content:"
                        dir
                        echo "Checking Frontend content:"
                        dir GameStore.Frontend
                    '''
                }
            }
        }

        stage('Build and Start Services') {
            steps {
                script {
                    try {
                        // Stop any running containers first
                        bat 'docker-compose down -v'
                        
                        // Build and start all services using docker-compose
                        bat 'docker-compose build --no-cache'
                        bat 'docker-compose up -d'
                        
                        // Use PowerShell Start-Sleep instead of timeout
                        bat 'powershell -Command "Start-Sleep -Seconds 30"'
                        
                        // Show running containers
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

        stage('Health Check') {
            steps {
                script {
                    bat '''
                        @echo off
                        echo "Starting health checks..."
                        
                        REM Wait for backend
                        set attempts=60
                        :WAIT_BACKEND
                        echo "Checking backend health..."
                        powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5274' -UseBasicParsing; exit 0 } catch { exit 1 }"
                        if %ERRORLEVEL% NEQ 0 (
                            set /a attempts-=1
                            if %attempts% LEQ 0 (
                                echo "Backend service failed to start"
                                exit 1
                            )
                            echo "Backend not ready, waiting 5 seconds... (%attempts% attempts remaining)"
                            powershell -Command "Start-Sleep -Seconds 5"
                            goto WAIT_BACKEND
                        )
                        
                        REM Wait for frontend
                        set attempts=60
                        :WAIT_FRONTEND
                        echo "Checking frontend health..."
                        powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5002' -UseBasicParsing; exit 0 } catch { exit 1 }"
                        if %ERRORLEVEL% NEQ 0 (
                            set /a attempts-=1
                            if %attempts% LEQ 0 (
                                echo "Frontend service failed to start"
                                exit 1
                            )
                            echo "Frontend not ready, waiting 5 seconds... (%attempts% attempts remaining)"
                            powershell -Command "Start-Sleep -Seconds 5"
                            goto WAIT_FRONTEND
                        )
                        
                        echo "All services are healthy!"
                    '''
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
                    bat 'docker system prune -f'
                    cleanWs()  // Clean workspace after build
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
