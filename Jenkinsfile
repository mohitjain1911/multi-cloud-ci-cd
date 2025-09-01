pipeline {
    agent any

    environment {
        AWS_REGION   = 'us-east-1'
        EKS_CLUSTER  = 'flask-task-manager-eks'
        AKS_CLUSTER  = 'flask-task-manager-aks'
        AKS_RG       = 'flask-task-rg'
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

                      # Helm deploy to EKS
                      helm upgrade --install flask-task-manager ./helm-chart \
                        --set image.repository=${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to AKS with Helm') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'azure-service-principal',
                        usernameVariable: 'AZURE_CLIENT_ID',
                        passwordVariable: 'AZURE_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'AZURE_TENANT_ID'),
                    string(credentialsId: 'azure-subscription-id', variable: 'AZURE_SUBSCRIPTION_ID')
                ]) {
                    sh """
                      # Login to Azure with Service Principal
                      az login --service-principal -u ${AZURE_CLIENT_ID} -p ${AZURE_CLIENT_SECRET} --tenant ${AZURE_TENANT_ID}
                      az account set --subscription ${AZURE_SUBSCRIPTION_ID}

                      # Configure kubeconfig for AKS
                      az aks get-credentials --resource-group ${AKS_RG} --name ${AKS_CLUSTER} --overwrite-existing

                      # Helm deploy to AKS
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
            echo "✅ Deployment completed successfully on both EKS & AKS: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}
