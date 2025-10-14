## `variables.tf`

variable "name"                { 
  description = "Nom de la Web App"           
   type = string
    }
variable "resource_group_name" { 
  description = "Resource Group" 
                type = string 
                }
variable "location"            { 
  description = "Région"                      
    type = string 
    }

variable "sku_name" {
   description = "SKU du plan (ex: B1, P1v3)"
    type = string  
    default = "B1"
     }

variable "public"  {
   description = "true = public, false = privé (PE + DNS)" 
   type = bool
    default = true
    }

# Requis si public = false
variable "subnet_id" {
  description = "Subnet pour le Private Endpoint"
  type        = string
  default     = null
  validation {
    condition     = var.public || (var.subnet_id != null && var.subnet_id != "")
    error_message = "Quand public = false, 'subnet_id' est requis."
  }
}

variable "private_dns_zone_id" {
  description = "ID de la Private DNS Zone 'privatelink.azurewebsites.net'"
  type        = string
  default     = null
  validation {
    condition     = var.public || (var.private_dns_zone_id != null && var.private_dns_zone_id != "")
    error_message = "Quand public = false, 'private_dns_zone_id' est requis."
  }
}

# App Settings
variable "app_settings" { 
  description = "App Settings" 
  type = map(string) 
  default = {} 
  }

# === SITE CONFIG — EXACT ===
variable "app_command_line" { 
  description = "Commande de démarrage"
   type = string 
   default = null 
   }

variable "container_registry_use_managed_identity" {
  description = "Utiliser MSI pour ACR"
  type        = bool
  default     = false
}

variable "container_registry_managed_identity_client_id" {
  description = "Client ID d'une User Assigned Identity (laisser null pour SystemAssigned)"
  type        = string
  default     = null
}

variable "docker_image_name" {
  description = "Image + tag (ex: repo/app:1.0.0)"
  type        = string
}

variable "docker_registry_url" {
  description = "URL du registry (ex: https://myacr.azurecr.io ou https://index.docker.io)"
  type        = string
}

variable "docker_registry_username" {
  description = "Nom d'utilisateur du registry (laisser null si MSI)"
  type        = string
  default     = null
}

# Optionnel: logs & CORS

variable "cors_allowed_origins"      { 
  description = "CORS origins"      
   type = list(string)
    default = [] 
   }
variable "cors_support_credentials"   { 
  description = "CORS credentials"  
    type = bool      
    default = false 
      }



variable "tags" { 
  description = "Tags" 
  type = map(string) 
  default = {} 
  }
variable logs {
  type =object({
    application_logs_file_system_level = string
    http_logs  = object({
    file_system = object({
    retention_in_days = number
    retention_in_mb   = number     
     })     
    })
  })
  default = {
    application_logs_file_system_level = "Verbose"
    http_logs = {
      file_system = {
        retention_in_days = 7
        retention_in_mb   = 25
      }
    }
  }
}
variable "service_plan_id" {
  description = "ID du Service Plan (App Service Plan)"
  type        = string
} 

variable "identity_ids" {
  description = "Liste des IDs des User Assigned Identities (laisser vide si SystemAssigned uniquement)"
  type        = list(string)
  default     = []
}

variable identity {
  type = string
  default = "UserAssigned"
}

variable "key_vault_reference_identity_id" {
  description = "Client ID de l'identité (SystemAssigned ou UserAssigned) utilisée pour accéder aux références Key Vault dans les App Settings (laisser null pour ne pas activer cette fonctionnalité)"
  type        = string
  default     = null
}