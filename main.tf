terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.11, < 4.0"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
}
data "azurerm_client_config" "current" {
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "jizan-terraform"
  location = var.region
}


module "network" {
  source  = "Azure/network/azurerm"
  version = "5.0.0"
  # insert the 2 required variables here
  resource_group_name = azurerm_resource_group.rg.name
  use_for_each = false
  subnet_names = [
    "Application",
    "Infra"
  ]
  subnet_prefixes = [
    var.subnet1,
    var.subnet2
  ]
  address_space = var.ip_rang
  resource_group_location = var.region
  vnet_name = "Main_Vnet"
}

resource "azurerm_key_vault" "KY" {
  name = "Main_Keyvault"
  location = var.region
  resource_group_name = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled = false
  sku_name = "Standard"

  access_policy = [ {
    Application_id = data.azurerm_client_config.current.Application_id
    certificate_permissions = [ "Get" ]
    key_permissions = [ "Get" ]
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [ "Get" ]
    storage_permissions = [ "Get" ]
    tenant_id = data.azurerm_client_config.current.tenant_id
  } ]
}

