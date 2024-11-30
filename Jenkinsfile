pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'abhishek626/k8s-react-app' // Correctly formatted with your Docker Hub username
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds' // Jenkins credentials ID for Docker Hub
        EC2_IP = '3.86.233.183'
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
                stage('Deploy to EC2 Minikube') {
            steps {
                withCredentials([file(credentialsId: 'EC2_KP', variable: 'SSH_KEY_FILE')]) {
                    script {
                        // SSH into EC2 instance and check Minikube status
                        sh """
                    ssh -i ${SSH_KEY_FILE} ubuntu@${EC2_IP} '
                    if ! minikube status | grep -q "Running"; then
                        echo "Starting Minikube..."
                        minikube start --driver=docker
                    else
                        echo "Minikube is already running."
                    fi

                    # Copy deployment and service files
                    cp deployment.yaml ./deployment.yaml
                    cp service.yaml ./service.yaml

                    # Deploy the application using the Docker image
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml

                    # Expose the deployment
                    kubectl expose deployment react-app --type=NodePort --port=80

                    # Get the Minikube IP and NodePort
                    minikube_ip=\$(minikube ip)
                    kubectl get services react-app
                    echo "Access your application at: http://\${minikube_ip}:<NodePort>"
                    '
                    """
                    }
                }
            }
                }
    }
    post {
        success {
            echo 'Deployment Successful! Access your app via the provided URL.'
        }
        failure {
            echo 'Deployment Failed! Check the logs.'
        }
    }
}
