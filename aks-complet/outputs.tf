output "id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "ID du cluster"
}

output "name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "Nom du cluster"
}

output "location" {
  value       = azurerm_kubernetes_cluster.this.location
  description = "Région"
}

output "fqdn" {
  value       = azurerm_kubernetes_cluster.this.fqdn
  description = "FQDN public (si applicable)"
}

output "private_fqdn" {
  value       = try(azurerm_kubernetes_cluster.this.private_fqdn, null)
  description = "FQDN privé (si applicable)"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.this.node_resource_group
  description = "Node Resource Group"
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
  description = "Issuer OIDC"
}

output "kube_admin_config_raw" {
  value     = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive = true
}

output "kubelet_identity_object_id" {
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id, null)
  description = "Object ID de l'identité kubelet"
}

output "key_vault_secrets_provider" {
  value     = try(azurerm_kubernetes_cluster.this.key_vault_secrets_provider, null)
  sensitive = true
}
