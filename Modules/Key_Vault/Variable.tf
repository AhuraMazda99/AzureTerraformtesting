variable "Key_vault_name" {
  description = "The name of the key Vault"
  type = string
}
variable "sku" {
  description = "Sku premium or standard"
  type = string
}
variable "tenent_id" {
  description = "tenent_id"
  type = string
}
variable "object_id" {
  description = "Object id"
  type = string
}
variable "rg" {
  description = "Respurce group"
  type = string
}

variable "location" {
  description = "Location"
  type = string
}