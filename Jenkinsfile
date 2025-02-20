pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'abhishek626/k8s-react-app' // Docker Hub image name
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds' // Jenkins credentials ID
        EC2_IP = '3.86.233.183'
    }
    stages {
        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Build the Docker image and push it to Docker Hub
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                        # Build the Docker image
                        docker build -t ${DOCKER_IMAGE}:latest .

                        # Login to Docker Hub
                        echo "\$DOCKER_PASSWORD" | docker login -u "\$DOCKER_USERNAME" --password-stdin

                        # Push the Docker image to the registry
                        docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
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
                            scp -o StrictHostKeyChecking=no -i /tmp/ssh_key deployment.yaml service.yaml ubuntu@${EC2_IP}:/home/ubuntu/

                            # SSH into the instance and perform Docker login and deploy
                            ssh -o StrictHostKeyChecking=no -i /tmp/ssh_key ubuntu@${EC2_IP} '
                            echo "\$DOCKER_PASSWORD" | docker login -u "\$DOCKER_USERNAME" --password-stdin

                            if ! minikube status | grep -q "Running"; then
                                echo "Starting Minikube..."
                                minikube start --driver=docker
                            else
                                echo "Minikube is already running."
                            fi

                            # Cleanup existing deployment and service if they exist
                            kubectl delete deployment react-app --ignore-not-found
                            kubectl delete service react-app --ignore-not-found

                            # Deploy the application using the new configuration
                            kubectl apply -f /home/ubuntu/deployment.yaml
                            kubectl apply -f /home/ubuntu/service.yaml

                            # Wait for the pod to be running
                            echo "Waiting for the pod to be in running state..."
                            while [[ \$(kubectl get pods -l app=react-app -o jsonpath='{.items[0].status.phase}') != "Running" ]]; do
                                sleep 2
                            done
                            echo "Pod is running!"

                            # Start port forwarding in the background
                            nohup kubectl port-forward svc/react-app 8080:80 --address 0.0.0.0 > port-forward.log 2>&1 &
                            echo "\$!" > port_forwarding_pid.txt  # Save the new PID

                            # Print out the EC2 public IP for accessing the app
                            echo "Access your application at: http://${EC2_IP}:8080"
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
