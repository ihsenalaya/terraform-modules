# cet exemple prevoit que le resource groupe est deja creer sous le nom vnet

data "azurerm_resource_group" "vnet" {
    name     = "rg-network-demo"
}

resource "azurerm_network_security_group" "nsg_pe" {
  name                = "nsg-private-endpoints"
  resource_group_name = data.azurerm_resource_group.vnet.name
  location            = data.azurerm_resource_group.vnet.location
}
resource "azurerm_network_security_group" "nsg_aks" {
  name                = "nsg-aks"
  resource_group_name = data.azurerm_resource_group.vnet.name
  location            = data.azurerm_resource_group.vnet.location
}
resource "azurerm_route_table" "rt_default" {
  name                = "rt-default"
  resource_group_name = data.azurerm_resource_group.vnet.name
  location            = data.azurerm_resource_group.vnet.location
}

# ---- Appel du module ----
module "vnet" {
  source = "git::https://github.com/ihsenalaya/terraform-modules.git//vnet?ref=main"

  # Global / RG
  resource_group_name = data.azurerm_resource_group.vnet.name
  # location = "westeurope"  # optionnel : si non fourni, hérite du RG via coalesce()

  # VNet
  vnet_name     = "vnet-demo"
  address_space = ["10.60.0.0/16"]
  dns_servers   = []                 # Azure DNS
  edge_zone     = null
  private_endpoint_vnet_policies = "Disabled"
  tags = {
    Env   = "dev"
    Owner = "platform"
    AsCode = "Terraform"
  }

  # Subnets (3 exemples : AKS, Private Endpoints, ACI délégué)
  subnets = {
    # Subnet pour nœuds AKS (pas de délégation)
    "snet-aks" = {
      address_prefixes                              = ["10.60.1.0/24"]
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
      default_outbound_access_enabled               = true
      service_endpoints                             = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegated_subnets                             = []
    }

    # Subnet dédié aux Private Endpoints (politiques PE désactivées)
    "snet-pe" = {
      address_prefixes                              = ["10.60.2.0/24"]
      private_endpoint_network_policies             = "Disabled"
      private_link_service_network_policies_enabled = true
      default_outbound_access_enabled               = true
      service_endpoints                             = []
      delegated_subnets                             = []
    }

    # Subnet délégué à Azure Container Instances
    "snet-aci" = {
      address_prefixes                              = ["10.60.3.0/24"]
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
      default_outbound_access_enabled               = true
      service_endpoints                             = []
      delegated_subnets = [{
        delegation_name = "aci-delegation"
        service_name    = "Microsoft.ContainerInstance/containerGroups"
        actions         = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }]
    }
  }

  # Associations NSG (clé = nom du subnet)
  nsg_ids = {
    "snet-aks" = azurerm_network_security_group.nsg_aks.id
    "snet-pe"  = azurerm_network_security_group.nsg_pe.id
    # "snet-aci" = azurerm_network_security_group.nsg_aks.id  # exemple si tu veux aussi l’associer
  }

  # Associations UDR (clé = nom du subnet)
  route_tables_ids = {
    "snet-aks" = azurerm_route_table.rt_default.id
    "snet-pe"  = azurerm_route_table.rt_default.id
  }
}