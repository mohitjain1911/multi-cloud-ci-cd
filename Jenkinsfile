pipeline {
    agent any

    environment {
        AWS_REGION   = 'us-east-1'
        EKS_CLUSTER  = 'flask-task-manager-eks'
        IMAGE_NAME   = 'tsmohitjain/flask-task-manager'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    def IMAGE_TAG = "build-${env.BUILD_NUMBER}"
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ./flask-task-manager"
                    env.IMAGE_TAG = IMAGE_TAG
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    sh """
                      echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
                      docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to EKS with Helm') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                      export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                      export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

                      # Configure kubeconfig for EKS
                      aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER}

                      # Helm deploy
                      helm upgrade --install flask-task-manager ./helm-chart \
                        --set image.repository=${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}
