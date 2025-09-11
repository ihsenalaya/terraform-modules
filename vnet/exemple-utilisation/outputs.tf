output "vnet_id"            { value = module.vnet.vnet_id }
output "vnet_name"          { value = module.vnet.vnet_name }
output "vnet_location"      { value = module.vnet.vnet_location }
output "vnet_address_space" { value = module.vnet.vnet_address_space }
output "vnet_subnets_ids"   { value = module.vnet.vnet_subnets }

# Très pratique :
output "subnets_by_name"    { value = module.vnet.subnets_by_name }
