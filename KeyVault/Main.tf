data "azurerm_client_config" "current" {
}
module "Key_vault" {
  source = "./Modules/Key_Vault"
  Key_vault_name = "Jizan-keyvaultname"
  sku = "standard"
  tenent_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  rg = output.resource_group_name
  location = var.region
}

