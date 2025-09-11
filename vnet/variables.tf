#---------------------------------------------------------------------
# Global
#---------------------------------------------------------------------
variable "location" {
  description = "Location du VNet. Par défaut: hérite du RG."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Nom du Resource Group."
  type        = string
}

#---------------------------------------------------------------------
# Tags
#---------------------------------------------------------------------
variable "tags" {
  type = map(string)
  default = { AsCode = "Terraform" }
  description = "Tags à appliquer."
}

#---------------------------------------------------------------------
# VNet
#---------------------------------------------------------------------
variable "vnet_name" {
  description = "Nom du VNet."
  type        = string
}

# v4 traite address_space en Set côté provider ; list(string) reste accepté si non indexé
variable "address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Address space du VNet."
}

variable "edge_zone" {
  type        = string
  default     = null
  description = "Edge Zone (force un nouveau VNet si modifiée)."
}

variable "private_endpoint_vnet_policies" {
  type        = string
  default     = "Disabled" # ou "Basic"
  description = "Private Endpoint VNet Policies: Disabled | Basic."
  validation {
    condition     = contains(["Disabled", "Basic"], var.private_endpoint_vnet_policies)
    error_message = "private_endpoint_vnet_policies doit être 'Disabled' ou 'Basic'."
  }
}

variable "dns_servers" {
  type        = list(string)
  default     = []
  description = "DNS servers (Azure DNS par défaut si vide)."
}

#---------------------------------------------------------------------
# Subnets
#---------------------------------------------------------------------
variable "subnets" {
  description = "Dictionnaire des subnets à créer."
  type = map(object({
    address_prefixes = list(string)

    # v4: string avec 4 valeurs possibles
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    default_outbound_access_enabled               = optional(bool, true)

    # Toujours supporté. (Si tu veux gérer par localisation, ajoute un autre champ et n’envoie qu’un des deux.)
    service_endpoints = optional(list(string))

    delegated_subnets = optional(list(object({
      delegation_name = string
      service_name    = string
      actions         = list(string)
    })))
  }))

  validation {
    condition = alltrue([
      for s in values(var.subnets) :
      s.private_endpoint_network_policies == null
      || contains(
        ["Disabled","Enabled","NetworkSecurityGroupEnabled","RouteTableEnabled"],
        s.private_endpoint_network_policies
      )
    ])
    error_message = "private_endpoint_network_policies doit être l'une de: Disabled, Enabled, NetworkSecurityGroupEnabled, RouteTableEnabled."
  }
}

#---------------------------------------------------------------------
# Associations
#---------------------------------------------------------------------
variable "nsg_ids" {
  description = "Map: nom du subnet -> NSG ID."
  type        = map(string)
  default     = {}
}

variable "route_tables_ids" {
  description = "Map: nom du subnet -> Route Table ID."
  type        = map(string)
  default     = {}
}
