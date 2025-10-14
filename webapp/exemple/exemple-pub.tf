module "webapp_public" {
  source              = "../"
  name                = "demo-webapp-pub-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id    = azurerm_service_plan.appserviceplan.id
  identity_ids = ["/subscriptions/ec0e829d-64e1-43fd-b721-ecf5b5112773/resourceGroups/ihsen/providers/Microsoft.ManagedIdentity/userAssignedIdentities/jumphost"]  # User Assigned Identity (optionnel)
  public   = true
  cors_allowed_origins    = ["https://myfrontendapp.com"]
  docker_image_name   = "library/nginx:alpine"
  docker_registry_url = "https://index.docker.io"
  app_settings = {
    "APPINSIGHTS_PROFILERFEATURE_VERSION"           = "1.0.0"
  }
  app_command_line                              = "hypercorn jask.web.main:app --workers 2 --bind 0.0.0.0:80"
  container_registry_use_managed_identity       = true
  container_registry_managed_identity_client_id = "f4ead7d3-35db-4012-ac43-6772aca78005"  
  key_vault_reference_identity_id = "/subscriptions/ec0e829d-64e1-43fd-b721-ecf5b5112773/resourceGroups/ihsen/providers/Microsoft.ManagedIdentity/userAssignedIdentities/jumphost"  # User Assigned Identity (optionnel)


    }
