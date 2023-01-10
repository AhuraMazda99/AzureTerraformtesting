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

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "jizan-terraform"
  location = var.region
}

module "network" {
  source  = "Azure/network/azurerm"
  version = "5.0.0"
  # insert the 2 required variables here
  resource_group_name = azurerm_resource_group.rg
  use_for_each = false
  
}
