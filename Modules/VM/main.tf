resource "azurerm_windows_virtual_machine" "vm_test_Windows_2016" {
  name = var.name
  location = var.region
  resource_group_name = var.resource_group_name
  size = "Standard_D2s_v3"
  network_interface_ids = var.network_interface_id
  admin_username = var.admin_username
  admin_password = module.Secret_adminpassword.ID
  
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