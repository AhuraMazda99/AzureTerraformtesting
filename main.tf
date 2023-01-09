terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
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

module "vnet-Main" {
  source  = "Azure/vnet/azurerm"
  version = "~> 4.0.0"
  # insert the 3 required variables here
  resource_group_name = azurerm_resource_group.rg

  use_for_each = false

  vnet_location = var.region

address_space = var.ip_rang


  subnet_names = [
  "Apllication",
  "Infrastructure",
  ]

  subnet_prefixes = [
  var.subnet1,
  var.subnet2
  ]

}