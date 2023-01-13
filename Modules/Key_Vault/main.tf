resource "azurerm_key_vault" "KY" {
  name = var.Key_vault_name
  location = var.region
  resource_group_name = var.rg
  enabled_for_disk_encryption = true
  tenant_id = var.tenent_id
  soft_delete_retention_days = 7
  purge_protection_enabled = false
  sku_name = var.sku
    access_policy {
    tenant_id = var.tenent_id
    object_id = var.object_id
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
