
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "ai_platform" {
  name     = "rg-enterprise-ai-platform"
  location = "southeastasia"

  tags = {
    environment = "development"
    managed_by  = "terraform"
    project     = "enterprise-ai-platform"
  }
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "enterprise-ai-aks"
  location            = azurerm_resource_group.ai_platform.location
  resource_group_name = azurerm_resource_group.ai_platform.name
  dns_prefix          = "enterprise-ai-platform"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2as_v5"
  }

  identity {
    type = "SystemAssigned"
  }
}


