pipeline {
    agent any

    environment {
        // Define environment variables
        DOCKER_IMAGE = 'your-docker-image-name' // Replace this with your actual Docker image name
        DOCKER_REGISTRY = 'your-docker-registry'  // e.g., docker.io/yourusername
        GITHUB_REPO_URL = 'https://github.com/yourusername/your-repo.git' // Replace with your actual GitHub repository URL
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials' // Jenkins credentials ID for Docker Hub
    }

    stages {
        stage('first test') {
            steps {
                script {
                    sh "echo 'hello world'"
                }
            }
        }

        // stage('Build Docker Image') {
        //     steps {
        //         // Build the Docker image
        //         sh 'docker build -t $DOCKER_IMAGE:latest .'
        //     }
        // }
        // stage('Push to Docker Registry') {
        //     steps {
        //         script {
        //             // Login to Docker Hub
        //             withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
        //                 sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
        //             }
        //         }
        //         // Push the Docker image to the registry
        //         sh "docker push $DOCKER_IMAGE:latest"
        //     }
        // }
        // stage('Deploy to Kubernetes') {
        //     steps {
        //         script {
        //             // Update the deployment with the new image
        //             sh """
        //             kubectl set image deployment/react-app react-app=${DOCKER_IMAGE}:latest
        //             """
        //         }
        //     }
        // }
    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed! Check the logs.'
        }
    }
}