pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'abhishek626/k8s-react-app' // Docker Hub image name
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
                sh "docker push $DOCKER_IMAGE:latest" // Push to Docker Hub
            }
        }
        stage('Deploy to EC2 Minikube') {
            steps {
                withCredentials([file(credentialsId: 'EC2_KP', variable: 'SSH_KEY_FILE')]) {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        script {
                            sh """
                            cp ${SSH_KEY_FILE} /tmp/ssh_key
                            chmod 600 /tmp/ssh_key

                            # Use scp to copy files from the Jenkins workspace to EC2
                            scp -o StrictHostKeyChecking=no -i /tmp/ssh_key deployment.yaml ubuntu@${EC2_IP}:/home/ubuntu/
                            scp -o StrictHostKeyChecking=no -i /tmp/ssh_key service.yaml ubuntu@${EC2_IP}:/home/ubuntu/
                            
                            # SSH into the instance and perform Docker login and deployment
                            ssh -o StrictHostKeyChecking=no -i /tmp/ssh_key ubuntu@${EC2_IP} '
                            echo "\$DOCKER_PASSWORD" | docker login -u "\$DOCKER_USERNAME" --password-stdin
                            if ! minikube status | grep -q "Running"; then
                                echo "Starting Minikube..."
                                minikube start --driver=docker
                            else
                                echo "Minikube is already running."
                            fi
                            
                            # Check and remove existing deployment and service
                            kubectl get deployment react-app && kubectl delete deployment react-app || echo "No existing deployment to delete."
                            kubectl get service react-app && kubectl delete service react-app || echo "No existing service to delete."

                            # Deploy the application using the new configuration
                            kubectl apply -f /home/ubuntu/deployment.yaml
                            kubectl apply -f /home/ubuntu/service.yaml

                            # Start port forwarding in the background
                            nohup kubectl port-forward svc/react-app 80:80 --address 0.0.0.0 &
                            
                            # Print out the Minikube IP
                            minikube_ip=\$(minikube ip)
                            echo "Access your application at: http://\${EC2_IP}"
                            '
                            """
                        }
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