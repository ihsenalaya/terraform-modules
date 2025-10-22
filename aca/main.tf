resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.env_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_app_environment" "cae" {
  name                       = var.env_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  tags                       = var.tags
}

# Identité managée (facultatif) pour tirer depuis ACR
resource "azurerm_user_assigned_identity" "uami" {
  count               = var.use_managed_identity ? 1 : 0
  name                = "${var.job_name}-uami"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.tags
}

# Donne AcrPull à l'identité si un ACR est fourni
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.use_managed_identity && var.acr_id != null ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.uami[0].principal_id
}

# Job ACA déclenché manuellement (on le démarre depuis le pipeline)
resource "azurerm_container_app_job" "job" {
  name                         = var.job_name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.cae.id

  # Journalisation & timeouts du job
  replica_timeout_in_seconds = 3600
  replica_retry_limit        = 1

  # Concurrence/terminaison d'une exécution
  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  # Identité sur la ressource (nécessaire si on utilise MI côté registry)
  dynamic "identity" {
    for_each = var.use_managed_identity ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.uami[0].id]
    }
  }

  # Secrets (PAT DevOps + mot de passe ACR si pas d'identité)
  secret {
    name  = "azp-token"
    value = var.azp_token
  }

  dynamic "secret" {
    for_each = (!var.use_managed_identity && var.registry_password != null) ? [1] : []
    content {
      name  = "acr-pwd"
      value = var.registry_password
    }
  }

  # Définition du(s) registre(s) d'images
  registry {
    server = var.registry_server
    # Si MI => on référence l'identité, sinon on passe username/password_secret
    identity             = var.use_managed_identity ? azurerm_user_assigned_identity.uami[0].id : null
    username             = var.use_managed_identity ? null : var.registry_username
    password_secret_name = var.use_managed_identity ? null : "acr-pwd"
  }

  template {
    container {
      name  = "ado-agent"
      image = var.container_image
      memory = "2Gi"
      cpu = "0.25"

 
      # Variables nécessaires à l'agent (override possible à l'exécution via --env-vars)
      env { 
        name = "AZP_URL"        
        value       = var.azp_url 
        }
      env { 
        name = "AZP_POOL"       
        value       = var.azp_pool
         }
      env { 
        name = "AZP_TOKEN"      
        secret_name = "azp-token" 
        }
      # Conseil : définissez AZP_AGENT_NAME au démarrage (voir snippet pipeline)

      # Ajout d'ENV supplémentaires en clair
      dynamic "env" {
        for_each = var.extra_env
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }
 tags = var.tags
 }

 