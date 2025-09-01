# 🌍 Multi-Cloud CI/CD with Jenkins, AWS EKS & Azure AKS

This project demonstrates a **multi-cloud CI/CD pipeline** using **Jenkins**, **Docker**, **Helm**, and **Terraform**, deploying a Flask application to both **Amazon EKS** and **Azure AKS**.

The pipeline automates:

* Building the app image
* Pushing to DockerHub
* Deploying via Helm to AWS + Azure clusters

---

## 📂 Project Structure

```
multi-cloud-ci-cd/
├── Jenkinsfile                # Jenkins pipeline definition
├── flask-task-manager/        # Flask application source
│   ├── Dockerfile
│   ├── app.py
│   ├── requirements.txt
│   └── templates/
├── helm-chart/                # Helm chart for deployment
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ingress.yaml
├── terraform/                 # Infrastructure as Code
│   ├── eks/                   # EKS cluster setup
│   └── aks/                   # AKS cluster setup
└── README.md
```

---

## ⚡ Prerequisites

Before starting, ensure you have:

* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Helm](https://helm.sh/docs/intro/install/)
* [Docker](https://docs.docker.com/get-docker/)
* A running **Jenkins server** with required plugins:

  * Pipeline
  * Git
  * Docker
  * Kubernetes CLI
  * Azure CLI
  * Credentials Binding

---

## 🚀 Infrastructure Setup (Terraform)

Provision Kubernetes clusters:

* **AWS EKS**:

  ```bash
  cd terraform/eks
  terraform init
  terraform plan -out=tfplan
  terraform apply tfplan
  ```

* **Azure AKS**:

  ```bash
  cd terraform/aks
  terraform init
  terraform plan -out=tfplan
  terraform apply tfplan
  ```

---

## 🔑 Jenkins Credentials Required

| ID                        | Type              | Usage                              |
| ------------------------- | ----------------- | ---------------------------------- |
| `dockerhub-creds`         | Username/Password | DockerHub login for pushing images |
| `aws-credentials`         | AWS Credentials   | Access key + secret for EKS        |
| `azure-service-principal` | Username/Password | Azure SP (AppId + Password)        |
| `azure-tenant-id`         | Secret Text       | Azure Tenant ID                    |
| `azure-subscription-id`   | Secret Text       | Azure Subscription ID              |

---

## ☁️ Cloud Setup

### 🔹 AWS (EKS)

1. Create an IAM User with programmatic access. Attach:

   * `AmazonEKSClusterPolicy`
   * `AmazonEKSWorkerNodePolicy`
   * `AmazonEC2ContainerRegistryFullAccess`

2. Save Access Key + Secret Key in Jenkins as `aws-credentials`.

3. Jenkins pipeline configures kubeconfig automatically:

   ```bash
   aws eks --region <region> update-kubeconfig --name <eks-cluster-name>
   ```

---

### 🔹 Azure (AKS)

1. Create a Service Principal:

   ```bash
   az ad sp create-for-rbac \
     --name jenkins-sp \
     --role Contributor \
     --scopes /subscriptions/<SUBSCRIPTION_ID>
   ```

   Example output:

   ```json
   {
     "appId": "xxxx-xxxx",     # Client ID
     "password": "xxxx-xxxx",  # Client Secret
     "tenant": "xxxx-xxxx"
   }
   ```

2. Save values in Jenkins:

   * `azure-service-principal` → (username: appId, password: password)
   * `azure-tenant-id` → tenant
   * `azure-subscription-id` → subscriptionId

3. Jenkins configures kubeconfig:

   ```bash
   az aks get-credentials --resource-group <rg> --name <aks-cluster>
   ```

---

## ⚙️ CI/CD Workflow (Jenkinsfile)

1. **Checkout** → GitHub repo
2. **Build Docker Image** → Flask app → `build-<BUILD_NUMBER>`
3. **Push to DockerHub**
4. **Deploy to AWS EKS (Helm)**
5. **Deploy to Azure AKS (Helm)**

---

## 🌐 Accessing the App

Once deployed:

```bash
kubectl get svc -n <namespace>
kubectl get ingress -n <namespace>
```

Example for LoadBalancer service:

```
http://<EXTERNAL-IP>:5000
```

---

## ✅ Final Output

* Flask app deployed on **AWS EKS** and **Azure AKS**
* Accessible via LoadBalancer or Ingress
* Automated builds & deployments on every Git push

---

## 📌 Notes

* Ensure Jenkins agents have `kubectl`, `aws-cli`, `az-cli`, `helm`, and `docker`.
* Update cluster names, resource group names, and image repository in:

  * `Jenkinsfile`
  * `helm-chart/values.yaml`

---

## 🤝 Contributions & Extensions

* Extend to **Google GKE** for true multi-cloud coverage.
* Replace DockerHub with **ECR/ACR** for cloud-native registries.
* Add monitoring with **Prometheus + Grafana**.

---

⚡ Built for learning **Multi-Cloud DevOps + CI/CD** 🚀

---