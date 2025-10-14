module "webapp_public" {
  source              = "./modules/linux-webapp"
  name                = "demo-webapp-pub-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  public   = true
  sku_name = "B1"

  # Site config
  docker_image_name   = "library/nginx:alpine"
  docker_registry_url = "https://index.docker.io"
  # docker_registry_username = null  # image publique -> inutile

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}

module "webapp_private" {
  source               = "./modules/linux-webapp"
  name                 = "demo-webapp-priv-001"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location

  public              = false
  sku_name            = "B1"
  subnet_id           = azurerm_subnet.appsvc_pe_subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.appsvc_plink.id  # 'privatelink.azurewebsites.net'

  # Site config (ACR + MSI)
  container_registry_use_managed_identity = true
  docker_image_name   = "apps/backend:1.0.0"   # repo:tag (sans host)
  docker_registry_url = "https://myacr.azurecr.io"
  # app_command_line  = "--port 8080"          # si nécessaire

  app_settings = {
    SOME_KEY = "some-value"
  }
}
