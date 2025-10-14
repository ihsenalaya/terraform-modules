terraform {
  required_version = ">= 1.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.48"
    }
  }
}

provider "azurerm" {
  features {}
}

# Plan App Service Linux
resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

# Web App Linux
resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only                    = true
  public_network_access_enabled = var.public

  app_settings = var.app_settings

  identity {
    type = var.enable_system_identity ? "SystemAssigned" : "None"
  }

  site_config {
    always_on = var.always_on

    app_command_line = coalesce(var.app_command_line, "")

    container_registry_use_managed_identity       = var.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = var.container_registry_managed_identity_client_id

    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = var.docker_registry_url
      docker_registry_username = var.docker_registry_username
      # Remarque: si vous utilisez l'identité managée pour ACR, laissez username vide/non défini.
    }
  }

  # Logs HTTP -> filesystem (simple)
  dynamic "logs" {
    for_each = var.enable_http_file_system_logs ? [1] : []
    content {
      http_logs {
        file_system {
          retention_in_days = var.http_logs_retention_in_days
          retention_in_mb   = var.http_logs_retention_in_mb
        }
      }
    }
  }

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

# Association du Private Endpoint à la Private DNS Zone (privatelink.azurewebsites.net)
resource "azurerm_private_dns_zone_group" "this" {
  count               = var.public ? 0 : 1
  name                = "${var.name}-pdzg"
  private_endpoint_id = azurerm_private_endpoint.this[0].id
  private_dns_zone_ids = [
    var.private_dns_zone_id
  ]
}
```hcl
terraform {
  required_version = ">= 1.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.48"
    }
  }
}

provider "azurerm" {
  features {}
}

# Plan App Service Linux
resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

# Web App Linux
resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only                    = true
  public_network_access_enabled = var.public

  app_settings = var.app_settings

  identity {
    type = var.enable_system_identity ? "SystemAssigned" : "None"
  }

  site_config {
    always_on = var.always_on

    # Application stack (simple) : Docker optionnel
    dynamic "application_stack" {
      for_each = var.docker_image != null ? [1] : []
      content {
        docker_image     = var.docker_image
        docker_image_tag = coalesce(var.docker_image_tag, "latest")
      }
    }

    # CORS (optionnel)
    dynamic "cors" {
      for_each = length(var.cors_allowed_origins) > 0 ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  # Logs HTTP -> filesystem (optionnel)
  dynamic "logs" {
    for_each = var.enable_http_file_system_logs ? [1] : []
    content {
      http_logs {
        file_system {
          retention_in_days = var.http_logs_retention_in_days
          retention_in_mb   = var.http_logs_retention_in_mb
        }
      }
    }
  }

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

# Association du Private Endpoint à la Private DNS Zone (privatelink.azurewebsites.net)
resource "azurerm_private_dns_zone_group" "this" {
  count               = var.public ? 0 : 1
  name                = "${var.name}-pdzg"
  private_endpoint_id = azurerm_private_endpoint.this[0].id
  private_dns_zone_ids = [
    var.private_dns_zone_id
  ]
}
