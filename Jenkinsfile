pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // Jenkins DockerHub credentials ID
        AWS_CREDENTIALS = credentials('aws-creds')             // Jenkins AWS IAM credentials ID
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER = 'flask-task-manager-eks'
        IMAGE_NAME = 'mohit/flask-task-manager'               // Your DockerHub repo
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    IMAGE_TAG = "build-${env.BUILD_NUMBER}"
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ./flask-task-manager"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Configure kubectl') {
            steps {
                script {
                    sh """
                    aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER}
                    """
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                script {
                    sh """
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
            echo "Deployment completed successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}

