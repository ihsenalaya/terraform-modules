
# module "webapp_private" {
#   source               = "../"
#   name                 = "demo-webapp-priv-001"
#   resource_group_name  = azurerm_resource_group.rg.name
#   location             = azurerm_resource_group.rg.location

#   public              = false
#   subnet_id           = azurerm_subnet.appsvc_pe_subnet.id
#   private_dns_zone_id = azurerm_private_dns_zone.appsvc_plink.id  # 'privatelink.azurewebsites.net'

#   # Site config (ACR + MSI)
#   container_registry_use_managed_identity = true
#   docker_image_name   = "apps/backend:1.0.0"   # repo:tag (sans host)
#   docker_registry_url = "https://myacr.azurecr.io"
#   # app_command_line  = "--port 8080"          # si nécessaire

#   app_settings = {
#     SOME_KEY = "some-value"
#   }
# }
