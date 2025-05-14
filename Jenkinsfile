pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = 'docker-hub'  // Jenkins credentials ID
        DOCKERHUB_USERNAME = 'oshadakavinda2' // Your Docker Hub username
        FRONTEND_IMAGE = 'oshadakavinda2/game-store-frontend'
        API_IMAGE = 'oshadakavinda2/game-store-api'
        AWS_CREDENTIALS = 'aws-credentials' // Jenkins credentials ID for AWS
        TF_LOG = 'DEBUG' // Enable Terraform debug logging
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
                                [$class: 'SparseCheckoutPath', path: '.gitignore'],
                                [$class: 'SparseCheckoutPath', path: 'terraform/']
                             ]]
                        ],
                        userRemoteConfigs: [[
                            url: 'https://github.com/oshadakavinda/Game-Store.git'
                        ]]
                    ])
                }
            }
        }
        
        stage('Docker Check') {
            steps {
                script {
                    try {
                        // Check if Docker is accessible
                        echo "Checking Docker availability..."
                        bat 'docker --version'
                        bat 'docker info'
                        echo "Docker is accessible"
                    } catch (Exception e) {
                        echo "Docker check failed: ${e.message}"
                        echo "Attempting to start Docker Desktop (if installed)..."
                        try {
                            // Try to start Docker Desktop if available
                            bat 'start "" "C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe"'
                            // Give it time to start
                            sleep(time: 30, unit: 'SECONDS')
                            // Check again
                            bat 'docker --version'
                            echo "Docker Desktop started successfully"
                        } catch (Exception e2) {
                            echo "Failed to start Docker Desktop: ${e2.message}"
                            currentBuild.result = 'FAILURE'
                            error("Docker is not accessible. Please ensure Docker is installed and running.")
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    try {
                        // Build Frontend and API images
                        echo "Starting Docker build for frontend..."
                        bat "docker build -t ${FRONTEND_IMAGE}:latest GameStore.Frontend/"
                        echo "Frontend image built successfully"
                        
                        echo "Starting Docker build for API..."
                        bat "docker build -t ${API_IMAGE}:latest GameStore.Api/"
                        echo "API image built successfully"
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
                            bat "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
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
        
        stage('Verify Terraform Files') {
            steps {
                script {
                    // Check if the terraform directory exists and contains the necessary files
                    bat 'dir terraform || mkdir terraform'
                    
                    // Check if main.tf exists, create if not
                    bat 'if not exist "terraform\\main.tf" echo Terraform main.tf file is missing'
                    
                    // List all files in terraform directory
                    bat 'dir terraform'
                }
            }
        }
        
        stage('Terraform Deploy') {
            steps {
                script {
                    // Use AWS credentials for Terraform
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                     credentialsId: AWS_CREDENTIALS,
                                     accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                     secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        dir('terraform') {
                            try {
                                // Set environment variables for debugging
                                bat 'set TF_LOG=DEBUG'
                                bat 'set TF_LOG_PATH=terraform.log'
                                
                                // Check Terraform installation
                                bat 'terraform version'
                                
                                // Initialize Terraform
                                echo "Initializing Terraform..."
                                bat 'terraform init -no-color'
                                
                                // Validate the configuration
                                echo "Validating Terraform configuration..."
                                bat 'terraform validate'
                                
                                // Plan Terraform changes
                                echo "Planning Terraform changes..."
                                bat 'terraform plan -no-color -out=tfplan'
                                
                                // Apply Terraform changes
                                echo "Applying Terraform changes..."
                                bat 'terraform apply -no-color -auto-approve tfplan'
                                
                                // Output results for verification
                                echo "Terraform output:"
                                bat 'terraform output'
                                
                                echo 'Terraform infrastructure deployment completed successfully'
                            } catch (Exception e) {
                                echo "Error during Terraform deployment: ${e.message}"
                                echo "Terraform diagnostic information:"
                                bat 'if exist terraform.log type terraform.log'
                                bat 'if exist .terraform.lock.hcl type .terraform.lock.hcl'
                                bat 'dir'
                                currentBuild.result = 'FAILURE'
                                error("Terraform deployment failed")
                            }
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Cleanup Docker images to prevent disk space issues
                try {
                    bat "docker logout"
                    echo "Logged out of Docker Hub"
                } catch (Exception e) {
                    echo "Docker logout failed: ${e.message}"
                }
                cleanWs()
            }
        }
        success {
            echo '✅ Docker images successfully pushed to Docker Hub and infrastructure deployed!'
        }
        failure {
            echo '❌ Pipeline failed! Check logs for details.'
        }
    }
}