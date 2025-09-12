terraform {
required_version = ">= 1.6.0"
required_providers {
azurerm = {
source = "hashicorp/azurerm"
version = ">= 3.100.0"
}
}
}


provider "azurerm" {
     features {}
 }


module "aks" {
source = "git::https://github.com/ihsenalaya/terraform-modules.git//aks?ref=main"


name = "aks-public-demo"
location = "westeurope"
resource_group_name = "rg-aks-public-demo"
dns_prefix = "pubdemo"


identity = {
type = "SystemAssigned"
}


rbac = {
enabled = true
managed_aad = true
admin_group_object_ids = []
azure_rbac_enabled = false
}


network = {
network_plugin = "azure"
network_policy = "azure"
vnet_subnet_id = "/subscriptions/0000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/sharedSubnets/snet-aks"
service_cidr = "10.2.0.0/16"
dns_service_ip = "10.2.0.10"
pod_cidr = null
load_balancer_sku = "standard"
}


default_pool = {
vm_size = "Standard_D4s_v5"
min_count = 1
max_count = 1
}


node_pools = {
userlinux = {
vm_size = "Standard_D4s_v5"
min_count = 0
max_count = 1
node_labels = { purpose = "apps" }
}
}
}