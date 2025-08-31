pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // Jenkins DockerHub credentials ID
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER = 'flask-task-manager-eks'
        IMAGE_NAME = 'tsmohitjain/flask-task-manager' // Your DockerHub repo
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/mohitjain1911/multi-cloud-ci-cd.git'
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
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                    export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                    export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
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
