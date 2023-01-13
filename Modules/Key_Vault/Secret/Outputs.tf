output "value" {
  value = azurerm_key_vault_secret.admin_password.value
}
output "ID" {
  value = azurerm_key_vault_secret.admin_password.id
}