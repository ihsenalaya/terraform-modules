variable "location" {
  description = "Région Azure"
  type        = string
  default     = "francecentral"
}

variable "rg_name" {
  description = "Nom du Resource Group"
  type        = string
}

variable "env_name" {
  description = "Nom de l'environnement Container Apps"
  type        = string
}

variable "job_name" {
  description = "Nom du Job ACA"
  type        = string
}

variable "container_image" {
  description = "Image de l'agent (ex: myacr.azurecr.io/ado-agent:1.0.0) — l'image doit exister avant l'apply"
  type        = string
}

variable "registry_server" {
  description = "Serveur du registre (ex: myacr.azurecr.io)"
  type        = string
}

variable "use_managed_identity" {
  description = "Si true, on utilise une UAMI pour tirer l'image (AcrPull)"
  type        = bool
  default     = true
}

variable "acr_id" {
  description = "ID de l'ACR (optionnel, requis si use_managed_identity=true pour assigner AcrPull)"
  type        = string
  default     = null
}

variable "registry_username" {
  description = "Utilisateur ACR (si on n'utilise pas de Managed Identity)"
  type        = string
  default     = null
}

variable "registry_password" {
  description = "Mot de passe ACR (si on n'utilise pas de Managed Identity)"
  type        = string
  sensitive   = true
  default     = null
}

variable "cpu" {
  description = "CPU pour le container (ex: 1, 0.5)"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Mémoire pour le container (ex: 2Gi)"
  type        = string
  default     = "2Gi"
}

# Variables pour l'agent Azure DevOps
variable "azp_url" {
  description = "URL de l'organisation DevOps (ex: https://dev.azure.com/ORG)"
  type        = string
}

variable "azp_pool" {
  description = "Nom du pool d'agents"
  type        = string
}

variable "azp_token" {
  description = "PAT Azure DevOps (secret)"
  type        = string
  sensitive   = true
}

variable "extra_env" {
  description = "Vars d'env additionnelles (clé => valeur clair)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags Azure"
  type        = map(string)
  default     = {}
}