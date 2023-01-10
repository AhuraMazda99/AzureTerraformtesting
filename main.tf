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
    var.subnet2,
  ]
  address_space = var.ip_rang
  resource_group_location = var.region
  vnet_name = "Main_Vnet"
}

resource "azurerm_network_interface" "Netinterface" {
  name = "network interface"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg

  ip_configuration {
    name = "vmtestnic"
    subnet_id = module.network.vnet_subnets.Application.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_key_vault" "KY" {
  name = "Jizanmainkeyvault"
  location = var.region
  resource_group_name = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled = false
  sku_name = "standard"
  access_policy = [ {
    application_id = data.azurerm_client_config.current.client_id
    certificate_permissions = [ "Get" ]
    key_permissions = [ "Get" ]
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [ "Get" ]
    storage_permissions = [ "Get" ]
    tenant_id = data.azurerm_client_config.current.tenant_id
  } ]
}

resource "azurerm_key_vault_key" "test" {
  key_vault_id = azurerm_key_vault.KY.id
  key_type = "RSA"
  key_size = 2048
  name = "adminkey"
  key_opts = [ 
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
   ]
}

resource "azurerm_key_vault_secret" "admin_password" {
  key_vault_id = azurerm_key_vault.KY.id
  value = "dragensliketodanceinthesky123!"
  name = "adminpassword"
}

resource "azurerm_windows_virtual_machine" "vm_test" {
  name = "vmtest"
  location = var.region
  resource_group_name = azurerm_resource_group.rg
  size = "Standard_D2s_v3"
  network_interface_ids = [azurerm_network_interface.Netinterface.id]
  admin_username = "adminNT"
  admin_password = azurerm_key_vault_secret.admin_password
os_disk {
  caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
}

source_image_reference {
  publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
}


}

