# Multi-Cloud CI/CD with Jenkins, AWS EKS & Azure AKS

A case study of building and deploying a **multi-cloud CI/CD pipeline** using **Jenkins, Docker, Helm, and Terraform**.  
This project demonstrates how a single pipeline can build a Flask app and deploy it simultaneously to **Amazon EKS** and **Azure AKS**, avoiding vendor lock-in.

---

## Problem
Organizations relying on a single cloud provider risk **vendor lock-in** and lack of resiliency.  
A solution is to create a **cloud-agnostic CI/CD pipeline** that works across providers with minimal manual effort.

---

## Solution
I designed and implemented a **Jenkins-based CI/CD pipeline** that:

- Builds and tests a **Flask application**
- Pushes images to **DockerHub**
- Provisions infrastructure using **Terraform**
- Deploys to **AWS EKS** and **Azure AKS** with **Helm**
- Uses **Jenkins credentials** to securely manage cloud access

---

## My Role
- Authored the **Jenkinsfile** for automated build → push → deploy
- Created reusable **Helm charts** for Kubernetes deployments
- Automated infrastructure setup with **Terraform** modules for EKS & AKS
- Configured Jenkins with **multi-cloud credentials**
- Documented the end-to-end workflow for reproducibility

---

## Outcome
- ✅ Fully automated CI/CD → single Git commit triggers deployments on AWS & Azure  
- ✅ Eliminated manual cluster setup using Terraform  
- ✅ Pipeline extensible to **Google GKE** or other clouds  
- ✅ Showcases practical **multi-cloud DevOps** approach  


## Project Structure

multi-cloud-ci-cd/
- Jenkinsfile
- flask-task-manager/
  - Dockerfile
  - app.py
  - requirements.txt
  - templates/
- helm-chart/
  - Chart.yaml
  - values.yaml
  - templates/
    - deployment.yaml
    - service.yaml
    - ingress.yaml
- terraform/
  - eks/
  - aks/
- README.md


---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads)  
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)  
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)  
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  
- [Helm](https://helm.sh/docs/intro/install/)  
- [Docker](https://docs.docker.com/get-docker/)  
- Jenkins with plugins: **Pipeline, Git, Docker, Kubernetes CLI, Azure CLI, Credentials Binding**

---

## Infrastructure Setup (Terraform)

Provision Kubernetes clusters:

### AWS EKS
```bash
cd terraform/eks
terraform init
terraform plan -out=tfplan
terraform apply tfplan
````

### Azure AKS

```bash
cd terraform/aks
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

---

## Jenkins Credentials Required

| ID                        | Type              | Usage                              |
| ------------------------- | ----------------- | ---------------------------------- |
| `dockerhub-creds`         | Username/Password | DockerHub login for pushing images |
| `aws-credentials`         | AWS Credentials   | Access key + secret for EKS        |
| `azure-service-principal` | Username/Password | Azure SP (AppId + Password)        |
| `azure-tenant-id`         | Secret Text       | Azure Tenant ID                    |
| `azure-subscription-id`   | Secret Text       | Azure Subscription ID              |

---

## Cloud Setup

### AWS (EKS)

1. Create an IAM User with:

   * `AmazonEKSClusterPolicy`
   * `AmazonEKSWorkerNodePolicy`
   * `AmazonEC2ContainerRegistryFullAccess`
2. Store access keys in Jenkins (`aws-credentials`).

### Azure (AKS)

1. Create a Service Principal:

   ```bash
   az ad sp create-for-rbac \
     --name jenkins-sp \
     --role Contributor \
     --scopes /subscriptions/<SUBSCRIPTION_ID>
   ```
2. Store appId, password, tenant, subscription ID in Jenkins credentials.

---

## CI/CD Workflow (Jenkinsfile)

1. **Checkout** GitHub repo
2. **Build Docker image** → `build-<BUILD_NUMBER>`
3. **Push image** to DockerHub
4. **Deploy to AWS EKS** with Helm
5. **Deploy to Azure AKS** with Helm

---

## Accessing the App

```bash
kubectl get svc -n <namespace>
kubectl get ingress -n <namespace>
```

Example:

```
http://<EXTERNAL-IP>:5000
```

---

## Final Output

* Flask app deployed on **AWS EKS** and **Azure AKS**
* Accessible via LoadBalancer or Ingress
* Pipeline automates deployments on every Git push

---

## Extensions

* Add **Google GKE** for true multi-cloud coverage
* Replace DockerHub with **ECR/ACR**
* Integrate monitoring with **Prometheus + Grafana**

---
Built for learning **Multi-Cloud DevOps + CI/CD** 








