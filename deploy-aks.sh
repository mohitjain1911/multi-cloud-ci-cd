#!/bin/bash

# Define base path
BASE_DIR="/home/mohit/multi-cloud-ci-cd/terraform/aks"

# Create directory
mkdir -p "$BASE_DIR"

# Create provider.tf
cat > "$BASE_DIR/provider.tf" <<'EOL'
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  required_version = ">= 1.4.0"
}

provider "azurerm" {
  features {}
}
EOL

# Create main.tf
cat > "$BASE_DIR/main.tf" <<'EOL'
resource "azurerm_resource_group" "rg" {
  name     = "flask-task-rg"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "flask-task-manager-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "flasktask"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
EOL

# Create variables.tf
cat > "$BASE_DIR/variables.tf" <<'EOL'
variable "resource_group_name" {
  default = "flask-task-rg"
}

variable "location" {
  default = "East US"
}

variable "cluster_name" {
  default = "flask-task-manager-aks"
}
EOL

# Create outputs.tf
cat > "$BASE_DIR/outputs.tf" <<'EOL'
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
EOL

echo "✅ Terraform AKS files created at: $BASE_DIR"

