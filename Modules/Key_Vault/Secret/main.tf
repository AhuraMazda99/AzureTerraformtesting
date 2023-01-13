resource "azurerm_key_vault_secret" "admin_password" {
  key_vault_id = var.key_vault_id
  value = var.value
  name = var.name
}