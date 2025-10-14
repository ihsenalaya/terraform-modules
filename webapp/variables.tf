variable "name" {
  description = "Nom de la Web App (unique dans Azure)."
  type        = string
}

variable "resource_group_name" {
  description = "Nom du Resource Group."
  type        = string
}

variable "location" {
  description = "Région Azure."
  type        = string
}

variable "sku_name" {
  description = "SKU du plan App Service (ex: B1, P1v3)."
  type        = string
  default     = "B1"
}

variable "public" {
  description = "true: Web App publique. false: Web App privée (Private Endpoint + DNS)."
  type        = bool
  default     = true
}

# Requis seulement si public = false
variable "subnet_id" {
  description = "ID de la subnet pour le Private Endpoint (même région que la Web App)."
  type        = string
  default     = null

  validation {
    condition     = var.public || (var.subnet_id != null && var.subnet_id != "")
    error_message = "Quand public = false, 'subnet_id' est requis."
  }
}

variable "private_dns_zone_id" {
  description = "ID de la Private DNS Zone 'privatelink.azurewebsites.net' à associer."
  type        = string
  default     = null

  validation {
    condition     = var.public || (var.private_dns_zone_id != null && var.private_dns_zone_id != "")
    error_message = "Quand public = false, 'private_dns_zone_id' est requis."
  }
}

# App Settings
variable "app_settings" {
  description = "Paires clé/valeur d'App Settings."
  type        = map(string)
  default     = {}
}

# Identity (SystemAssigned on/off)
variable "enable_system_identity" {
  description = "Active l'identity SystemAssigned."
  type        = bool
  default     = true
}

# Site config : paramètres demandés
variable "app_command_line" {
  description = "Commande de démarrage (facultatif)."
  type        = string
  default     = null
}

variable "container_registry_use_managed_identity" {
  description = "Utiliser l'identity managée pour tirer l'image (ex: ACR)."
  type        = bool
  default     = false
}

variable "container_registry_managed_identity_client_id" {
  description = "Client ID de l'User Assigned Identity pour ACR (laisser null pour SystemAssigned)."
  type        = string
  default     = null
}

variable "docker_image_name" {
  description = "Nom d'image + tag (ex: repo/app:tag)."
  type        = string
  default     = null
}

variable "docker_registry_url" {
  description = "URL du registry (ex: https://index.docker.io ou https://<acr>.azurecr.io)."
  type        = string
  default     = null
}

variable "docker_registry_username" {
  description = "Username pour le registry (laisser vide si MSI ACR)."
  type        = string
  default     = null
}

variable "always_on" {
  description = "Garder l'app éveillée (conseillé en prod)."
  type        = bool
  default     = true
}

# Logs HTTP vers File System
variable "enable_http_file_system_logs" {
  description = "Active les HTTP logs sur file system."
  type        = bool
  default     = true
}

variable "http_logs_retention_in_days" {
  description = "Rétention des logs HTTP (jours)."
  type        = number
  default     = 7
}

variable "http_logs_retention_in_mb" {
  description = "Taille max des logs HTTP (MB)."
  type        = number
  default     = 35
}

# Tags
variable "tags" {
  description = "Tags à appliquer."
  type        = map(string)
  default     = {}
}
```hcl
variable "name" {
  description = "Nom de la Web App (unique dans Azure)."
  type        = string
}

variable "resource_group_name" {
  description = "Nom du Resource Group."
  type        = string
}

variable "location" {
  description = "Région Azure."
  type        = string
}

variable "sku_name" {
  description = "SKU du plan App Service (ex: B1, P1v3)."
  type        = string
  default     = "B1"
}

variable "public" {
  description = "true: Web App publique. false: Web App privée (Private Endpoint + DNS)."
  type        = bool
  default     = true
}

# Requis seulement si public = false
variable "subnet_id" {
  description = "ID de la subnet pour le Private Endpoint (même région que la Web App)."
  type        = string
  default     = null

  validation {
    condition     = var.public || (var.subnet_id != null && var.subnet_id != "")
    error_message = "Quand public = false, 'subnet_id' est requis."
  }
}

variable "private_dns_zone_id" {
  description = "ID de la Private DNS Zone 'privatelink.azurewebsites.net' à associer."
  type        = string
  default     = null

  validation {
    condition     = var.public || (var.private_dns_zone_id != null && var.private_dns_zone_id != "")
    error_message = "Quand public = false, 'private_dns_zone_id' est requis."
  }
}

# App Settings
variable "app_settings" {
  description = "Paires clé/valeur d'App Settings."
  type        = map(string)
  default     = {}
}

# Identity (SystemAssigned on/off)
variable "enable_system_identity" {
  description = "Active l'identity SystemAssigned."
  type        = bool
  default     = true
}

# Site config : Docker (optionnel)
variable "docker_image" {
  description = "Image Docker (ex: mcr.microsoft.com/azuredocs/aks-helloworld). Si null, aucun stack Docker n'est configuré."
  type        = string
  default     = null
}

variable "docker_image_tag" {
  description = "Tag Docker (ex: latest)."
  type        = string
  default     = null
}

variable "always_on" {
  description = "Garder l'app éveillée (conseillé en prod)."
  type        = bool
  default     = true
}

# CORS
variable "cors_allowed_origins" {
  description = "Liste des origines autorisées pour CORS. Laisser vide pour ne pas activer CORS."
  type        = list(string)
  default     = []
}

variable "cors_support_credentials" {
  description = "Autoriser les credentials pour CORS."
  type        = bool
  default     = false
}

# Logs HTTP vers File System
variable "enable_http_file_system_logs" {
  description = "Active les HTTP logs sur file system."
  type        = bool
  default     = true
}

variable "http_logs_retention_in_days" {
  description = "Rétention des logs HTTP (jours)."
  type        = number
  default     = 7
}

variable "http_logs_retention_in_mb" {
  description = "Taille max des logs HTTP (MB)."
  type        = number
  default     = 35
}

# Tags
variable "tags" {
  description = "Tags à appliquer."
  type        = map(string)
  default     = {}
}
