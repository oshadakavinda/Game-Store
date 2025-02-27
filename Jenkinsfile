pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Rename Frontend Dockerfile') {
            steps {
                script {
                    // Rename DockerFile to Dockerfile for consistency
                    bat 'if exist GameStore.Frontend\\DockerFile rename GameStore.Frontend\\DockerFile Dockerfile'
                }
            }
        }

        stage('Build and Start Services') {
            steps {
                script {
                    try {
                        // Build and start all services using docker-compose
                        bat 'docker-compose build'
                        bat 'docker-compose up -d'
                    } catch (Exception e) {
                        echo "Error during build and start: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Build and start services failed")
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    // Wait for services to be healthy using PowerShell
                    bat '''
                        @echo off
                        
                        REM Wait for backend
                        set timeout=300
                        :WAIT_BACKEND
                        powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5274' -UseBasicParsing; exit 0 } catch { exit 1 }"
                        if %ERRORLEVEL% NEQ 0 (
                            set /a timeout-=5
                            if %timeout% LEQ 0 (
                                echo Backend service failed to start
                                exit 1
                            )
                            timeout /t 5 /nobreak
                            goto WAIT_BACKEND
                        )
                        
                        REM Wait for frontend
                        set timeout=300
                        :WAIT_FRONTEND
                        powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5002' -UseBasicParsing; exit 0 } catch { exit 1 }"
                        if %ERRORLEVEL% NEQ 0 (
                            set /a timeout-=5
                            if %timeout% LEQ 0 (
                                echo Frontend service failed to start
                                exit 1
                            )
                            timeout /t 5 /nobreak
                            goto WAIT_FRONTEND
                        )
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    // Clean up containers and volumes
                    bat 'docker-compose down -v'
                    // Remove -y flag as it's not supported
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
