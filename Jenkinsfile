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
                    // Using full clone since shallow clone is missing files
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/master']],
                        extensions: [
                            [$class: 'CleanBeforeCheckout']
                        ],
                        userRemoteConfigs: [[
                            url: 'https://github.com/oshadakavinda/Game-Store.git'
                        ]]
                    ])
                }
            }
        }

        stage('Debug Directory') {
            steps {
                script {
                    bat '''
                        echo "Current Directory Structure:"
                        dir /s /b
                        
                        echo "Frontend Directory Contents:"
                        dir GameStore.Frontend
                        
                        echo "Frontend Dockerfile:"
                        type GameStore.Frontend\\Dockerfile
                    '''
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
                        
                        bat '''
                            echo "Running Containers:"
                            docker ps
                            
                            echo "Container Logs:"
                            docker-compose logs
                        '''
                        
                        bat 'timeout /t 30 /nobreak'
                    } catch (Exception e) {
                        echo "Error during build and start: ${e.message}"
                        bat '''
                            echo "Docker Compose Logs:"
                            docker-compose logs
                            echo "Docker PS:"
                            docker ps -a
                        '''
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
                        set timeout=300
                        :WAIT_BACKEND
                        echo "Checking backend health..."
                        powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5274' -UseBasicParsing; exit 0 } catch { exit 1 }"
                        if %ERRORLEVEL% NEQ 0 (
                            set /a timeout-=5
                            if %timeout% LEQ 0 (
                                echo "Backend service failed to start"
                                exit 1
                            )
                            echo "Backend not ready, waiting 5 seconds..."
                            timeout /t 5 /nobreak
                            goto WAIT_BACKEND
                        )
                        
                        REM Wait for frontend
                        set timeout=300
                        :WAIT_FRONTEND
                        echo "Checking frontend health..."
                        powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5002' -UseBasicParsing; exit 0 } catch { exit 1 }"
                        if %ERRORLEVEL% NEQ 0 (
                            set /a timeout-=5
                            if %timeout% LEQ 0 (
                                echo "Frontend service failed to start"
                                exit 1
                            )
                            echo "Frontend not ready, waiting 5 seconds..."
                            timeout /t 5 /nobreak
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
