terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.43" # ou "~> 4.0"
    }
      random  = { 
        source = "hashicorp/random", version = ">= 3.6.2"
         }
  }
}
provider "azurerm" {
  features {}

  
provider "random" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg"
  location = "West Europe"
}

resource "azurerm_service_plan" "appserviceplan" {
    location = azurerm_resource_group.rg.location
    resource_group_name =   azurerm_resource_group.rg.name
    name = "serviceplan"
    os_type             = "Linux"
    sku_name            = "P1v2"
}