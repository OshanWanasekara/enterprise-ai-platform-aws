
output "resource_group_name" {
  value = azurerm_resource_group.ai_platform.name
}

output "resource_group_location" {
  value = azurerm_resource_group.ai_platform.location
}

output "resource_group_id" {
  value = azurerm_resource_group.ai_platform.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}


