pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'k8s-react-app' // Replace this with your actual Docker image name
        DOCKER_REGISTRY = 'docker.io/abhishek626'  // e.g., docker.io/yourusername
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds' // Jenkins credentials ID for Docker Hub
    }

    stages {

        stage('Build Docker Image') {
            steps {
                // Build the Docker image
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
                sh "docker push $DOCKER_IMAGE:latest"
            }
        }
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
