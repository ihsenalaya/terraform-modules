
output "id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "ID du cluster"
}

output "name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "Nom du cluster"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.this.kube_config
  sensitive   = true
  description = "Kubeconfig (admin)"
}

output "kubelet_identity_object_id" {
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id, null)
  description = "Object ID de l'identité kubelet"
}

output "fqdn" {
  value       = azurerm_kubernetes_cluster.this.fqdn
  description = "FQDN public (si applicable)"
}

output "private_fqdn" {
  value       = try(azurerm_kubernetes_cluster.this.private_fqdn, null)
  description = "FQDN privé (si applicable)"
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
  description = "URL de l'issuer OIDC (pour Workload Identity / fédération)"
}

output "oidc_issuer_enabled" {
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_enabled
  description = "OIDC issuer activé"
}

output "workload_identity_enabled" {
  value       = azurerm_kubernetes_cluster.this.workload_identity_enabled
  description = "Workload Identity activé"
}