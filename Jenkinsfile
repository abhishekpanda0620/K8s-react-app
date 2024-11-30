pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'abhishek626/k8s-react-app' // Correctly formatted with your Docker Hub username
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds' // Jenkins credentials ID for Docker Hub
    }
    stages {
        stage('Build Docker Image') {
            steps {
                // Build the Docker image with the correct naming
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }
        stage('Push to Docker Registry') {
            steps {
                script {
                    // Login to Docker Hub
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
                    }
                }
                // Push the Docker image to the registry
                sh "docker push $DOCKER_IMAGE:latest" // Now it will push to abhishek626/k8s-react-app
            }
        }
        // Uncomment the following block if you want to deploy to Kubernetes
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