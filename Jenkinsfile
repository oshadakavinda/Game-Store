pipeline {
    agent any

    options {
        timeout(time: 1, unit: 'HOURS') // Set a timeout for the pipeline
    }

    environment {
        REPO_URL = "https://github.com/your-username/your-repo.git" // Replace with your repository URL
        CLONE_DIR = "your-repo" // Replace with your desired clone directory
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs() // Clean the workspace before starting
            }
        }

        stage('Clone Repository') {
            steps {
                script {
                    // Check if the clone directory already exists
                    if (fileExists("${env.CLONE_DIR}")) {
                        echo "Directory ${env.CLONE_DIR} already exists. Deleting it..."
                        sh "rm -rf ${env.CLONE_DIR}"
                    }

                    // Clone the repository
                    echo "Cloning repository from ${env.REPO_URL} into ${env.CLONE_DIR}..."
                    sh "git clone ${env.REPO_URL} ${env.CLONE_DIR}"

                    // Check if the clone was successful
                    if (fileExists("${env.CLONE_DIR}")) {
                        echo "Repository cloned successfully!"
                    } else {
                        error "Failed to clone repository. Check the URL and try again."
                    }
                }
            }
        }

        stage('List Files') {
            steps {
                script {
                    // List files in the cloned repository
                    sh "ls -la ${env.CLONE_DIR}"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}
