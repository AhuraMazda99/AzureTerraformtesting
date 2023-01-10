data "azurerm_client_config" "current" {
  provider "client_id" {
    value = data.azurerm_client_config.current.client_id
  }
  provider "Tenent_id" {
    value = data.azurerm_client_config.current-tenant_id
  }
  provider "object_id" {
    value = data.azurerm_client_config.current-object_id
  }
}