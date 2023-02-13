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
















#Data inputs
data "azurerm_client_config" "current" {
}

















# Resource Groups
resource "azurerm_resource_group" "rg" {
  name     = "jizan-terraform"
  location = var.region
}

















#Networking
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
    public_ip_address_id = azurerm_public_ip.public-ip-vm.id
  }
}
resource "azurerm_public_ip" "public-ip-vm" {
  allocation_method = "Static"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.region
  name = "vm-public-ip-jizan"
}
resource "azurerm_network_security_group" "nsg" {
  name = "NSG-Main"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.region
  
security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "application-NSG-main" {
  subnet_id = azurerm_subnet.sub1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  
}

resource "azurerm_network_interface_security_group_association" "Vnet-Main-NSG" {
  network_interface_id = azurerm_network_interface.Netinterface.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}















#Key Vaults
module "Key_vault" {
  source = "./Modules/Key_Vault"
  Key_vault_name = "Jizan-keyvaultname"
  sku = "standard"
  tenent_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  rg = azurerm_resource_group.rg.name
  location = var.region
}

module "Secret_adminpassword" {
  source = "./Modules/Key_Vault/Secret"
  name = "adminpassword"
  value = "Kittenflyinthesky123!"
  key_vault_id = module.Key_vault.ID
}

















#VM
module "vm_test_Windows_2016" {
  source = "./Modules/VM"
  name = "vmtest"
  resource_group_name = azurerm_resource_group.rg.name
  admin_username = "adminNT"
  network_interface_id = [azurerm_network_interface.Netinterface.id]
  admin_password = module.Secret_adminpassword.value
  region = var.region
}




# resource "azurerm_windows_virtual_machine" "vm_test" {
# name = "vmtest"
# location = var.region
# resource_group_name = azurerm_resource_group.rg.name
# size = "Standard_D2s_v3"
# network_interface_ids = [azurerm_network_interface.Netinterface.id]
# admin_username = "adminNT"
# admin_password = module.Secret_adminpassword.ID

# os_disk {
# caching              = "ReadWrite"
# storage_account_type = "Standard_LRS"
# }
# source_image_reference {
# publisher = "MicrosoftWindowsServer"
# offer     = "WindowsServer"
# sku       = "2016-Datacenter"
# version   = "latest"
# }




#}

