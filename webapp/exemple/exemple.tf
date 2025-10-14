
## Exemples d’utilisation (minimal)

> Prérequis : un `azurerm_resource_group` ; pour le **privé**, une subnet dédiée PE et une Private DNS Zone `privatelink.azurewebsites.net` existantes.

### 1) Web App **publique**

```hcl
module "webapp_public" {
  source              = "./modules/linux-webapp"
  name                = "demo-webapp-pub-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  public  = true
  sku_name = "B1"

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}
```

### 2) Web App **privée** (Private Endpoint + DNS)

```hcl
module "webapp_private" {
  source               = "./modules/linux-webapp"
  name                 = "demo-webapp-priv-001"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location

  public              = false
  sku_name            = "B1"
  subnet_id           = azurerm_subnet.appsvc_pe_subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.appsvc_plink.id  # 'privatelink.azurewebsites.net'

  # Optionnel : CORS & Docker
  cors_allowed_origins = ["https://admin.example.com"]
  docker_image         = "mcr.microsoft.com/azuredocs/aks-helloworld"
  docker_image_tag     = "latest"

  app_settings = {
    SOME_KEY = "some-value"
  }
}
```

> **Note** : Pense à **lier** la Private DNS Zone au VNet consommateur via `azurerm_private_dns_zone_virtual_network_link`.
