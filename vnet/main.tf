// Module Azure Generic vNet — compatible AzureRM v4.43+
data "azurerm_resource_group" "vnet" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.vnet.name
  # IMPORTANT : éviter "" ; on hérite du RG si non fourni
  location            = coalesce(var.location, data.azurerm_resource_group.vnet.location)

  address_space = var.address_space
  dns_servers   = var.dns_servers
  edge_zone     = var.edge_zone

  # Nouveau depuis v4 : Disabled | Basic
  private_endpoint_vnet_policies = var.private_endpoint_vnet_policies

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  // v4: string (Disabled | Enabled | NetworkSecurityGroupEnabled | RouteTableEnabled)
  private_endpoint_network_policies             = lookup(each.value, "private_endpoint_network_policies", "Enabled")
  // Toujours booléen en v4
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", true)

  // Contrôle “internet par défaut” (par défaut = true côté API)
  default_outbound_access_enabled = lookup(each.value, "default_outbound_access_enabled", true)

  // Toujours supporté ; si tu veux la version par localisation, gère-la côté variable et n’envoie qu’un seul des deux attributs.
  service_endpoints = lookup(each.value, "service_endpoints", [])

  dynamic "delegation" {
    for_each = coalesce(each.value.delegated_subnets, [])
    content {
      name = delegation.value.delegation_name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

locals {
  azurerm_subnets = { for _, sn in azurerm_subnet.subnet : sn.name => sn.id }
}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each                  = var.nsg_ids
  subnet_id                 = local.azurerm_subnets[each.key]
  network_security_group_id = each.value
}

resource "azurerm_subnet_route_table_association" "vnet" {
  for_each       = var.route_tables_ids
  route_table_id = each.value
  subnet_id      = local.azurerm_subnets[each.key]
}
