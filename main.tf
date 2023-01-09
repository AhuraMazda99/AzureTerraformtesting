terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.0"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "jizan-terraform"
  location = var.region
}

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.0.0"
  # insert the 3 required variables here
  use_for_each = false 
  vnet_location = var.region
  resource_group_name = azurerm_resource_group.rg
}