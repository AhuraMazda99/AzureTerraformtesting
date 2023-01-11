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


resource "azurerm_virtual_network" "Vnetmain" {
  name = "Vnetmain"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.region
  address_space = [var.ip_rang]
}

resource "azurerm_subnet" "sub1" {
  name = "Application"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.Vnetmain.name
  address_prefixes = [var.subnet1]
  
}

resource "azurerm_subnet" "sub2" {
  name = "Infra"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.Vnetmain.name
  address_prefixes = [var.subnet2]
  
}
resource "azurerm_network_interface" "Netinterface" {
  name = "networkinterface"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "vmtestnic"
    subnet_id = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_security_group" "nsg" {
  name = "NSG-Main"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.region
  security_rule = [ {
    access = "Allow"
    description = "RDP"
    destination_address_prefix = "Any"
    destination_port_range = "3389"
    direction = "value"
    name = "rdp-rule"
    priority = 50
    protocol = "TCP"
  } ]
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
    access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get", "List", "Create", "Delete",
    ]
    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]
    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_key" "test" {
  key_vault_id = azurerm_key_vault.KY.id
  key_type = "RSA"
  key_size = 2048
  name = "test"
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
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_D2s_v3"
  network_interface_ids = [azurerm_network_interface.Netinterface.id]
  admin_username = "adminNT"
  admin_password = azurerm_key_vault_secret.admin_password.value
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

