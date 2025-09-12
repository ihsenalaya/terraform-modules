terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "aks" {
  # Garde ton chemin tel que dans ton exemple (racine /aks du repo).
  source = "git::https://github.com/ihsenalaya/terraform-modules.git//aks?ref=main"

  name                = "aks-quickstart"
  location            = "eastus"
  resource_group_name = "ihsen"
  dns_prefix          = "aksquick"

  # Pas d'ACR attaché, pas de monitoring -> rien de plus à déclarer

  # Public (API exposée), pas d'IP autorisées spécifiques (tu peux ajouter plus tard)
  private_cluster_enabled       = false
  public_network_access_enabled = true

  identity = {
    type = "SystemAssigned"
  }

  # Réseau minimal sans subnet ID -> KUBENET
  network = {
    network_plugin    = "kubenet"
    network_policy    = null
    service_cidr      = "10.20.0.0/16"
    dns_service_ip    = "10.20.0.10"
    pod_cidr          = null
    load_balancer_sku = "standard"
  }

  # Pool système minimal
  default_pool = {
    vm_size             = "Standard_D4s_v5"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
  }
}

# Sorties utiles
output "aks_id"               { value = module.aks.id }
output "aks_name"             { value = module.aks.name }
output "aks_fqdn"             { value = module.aks.fqdn }
output "aks_oidc_issuer_url"  { value = module.aks.oidc_issuer_url }
