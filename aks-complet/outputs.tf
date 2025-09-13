output "id"                       { value = azurerm_kubernetes_cluster.this.id }
output "name"                     { value = azurerm_kubernetes_cluster.this.name }
output "location"                 { value = azurerm_kubernetes_cluster.this.location }
output "fqdn"                     { value = azurerm_kubernetes_cluster.this.fqdn }
output "private_fqdn"             { value = azurerm_kubernetes_cluster.this.private_fqdn }
output "node_resource_group"      { value = azurerm_kubernetes_cluster.this.node_resource_group }
output "oidc_issuer_url"          { value = azurerm_kubernetes_cluster.this.oidc_issuer_url }
output "kube_admin_config_raw"    { value = azurerm_kubernetes_cluster.this.kube_admin_config_raw, sensitive = true }
output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
# Key Vault Secrets Provider identity (si exposé par le provider)
output "key_vault_secrets_provider" {
  value = try(azurerm_kubernetes_cluster.this.key_vault_secrets_provider, null)
  sensitive = true
}
