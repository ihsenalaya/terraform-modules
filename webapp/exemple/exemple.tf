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
