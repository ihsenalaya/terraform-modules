
---

## `outputs.tf`

```hcl
output "web_app_id" {
  value       = azurerm_linux_web_app.this.id
  description = "ID de la Web App."
}

output "default_hostname" {
  value       = azurerm_linux_web_app.this.default_hostname
  description = "Hostname par défaut (FQDN public d'Azure)."
}

output "principal_id" {
  value       = try(azurerm_linux_web_app.this.identity[0].principal_id, null)
  description = "Principal ID de l'identity (si activée)."
}

output "private_endpoint_id" {
  value       = try(azurerm_private_endpoint.this[0].id, null)
  description = "ID du Private Endpoint (si créé)."
}

output "private_endpoint_ip" {
  value       = try(azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address, null)
  description = "Adresse IP privée du Private Endpoint (si disponible)."
}
```