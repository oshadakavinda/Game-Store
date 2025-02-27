pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
                        
                        // Give services some time to start
                        bat 'timeout /t 30 /nobreak'
                    } catch (Exception e) {
                        echo "Error during build and start: ${e.message}"
                        bat 'docker-compose logs'  // Print logs for debugging
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
                    // Print logs before cleanup
                    bat 'docker-compose logs'
                    
                    // Clean up containers and volumes
                    bat 'docker-compose down -v'
                    bat 'docker system prune -f'
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
