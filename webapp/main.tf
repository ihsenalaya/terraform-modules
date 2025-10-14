# App Service Plan (Linux)
# resource "azurerm_service_plan" "this" {
#   name                = "${var.name}-plan"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   os_type             = "Linux"
#   sku_name            = var.sku_name
#   tags                = var.tags
# }

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  https_only                    = true
  public_network_access_enabled = var.public

  app_settings = var.app_settings

  identity {
    type = var.identity
    identity_ids = var.identity_ids
  }

  site_config {
    app_command_line = var.app_command_line
    container_registry_use_managed_identity       = var.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = var.container_registry_managed_identity_client_id

    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = var.docker_registry_url
      docker_registry_username = var.docker_registry_username
      # Si vous utilisez un login/password au lieu de MSI, exposez var.docker_registry_password et ajoutez l'attribut correspondant ici.
    }

    # CORS (simple)
    dynamic "cors" {
      for_each = length(var.cors_allowed_origins) > 0 ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  # Logs HTTP -> FileSystem (simple et optionnel)
   logs {
    application_logs {
      file_system_level = var.logs.application_logs_file_system_level
    }
    http_logs {
      file_system {
        retention_in_days = var.logs.http_logs.file_system.retention_in_days
        retention_in_mb   = var.logs.http_logs.file_system.retention_in_mb
      }
    }
  }
key_vault_reference_identity_id = var.key_vault_reference_identity_id
  tags = var.tags
}

# Private Endpoint (créé uniquement si public = false)
resource "azurerm_private_endpoint" "this" {
  count               = var.public ? 0 : 1
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-pe-conn"
    private_connection_resource_id = azurerm_linux_web_app.this.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}

# Association Private DNS Zone (privatelink.azurewebsites.net)
# resource "azurerm_private_dns_zone_group" "this" {
#   count               = var.public ? 0 : 1
#   name                = "${var.name}-pdzg"
#   private_endpoint_id = azurerm_private_endpoint.this[0].id
#   private_dns_zone_ids = [ var.private_dns_zone_id ]
# }

