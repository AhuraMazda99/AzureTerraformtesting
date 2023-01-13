variable "name" {
  description = "Name of Secret"
  type = string
}
variable "value" {
  description = "value of secret"
  type = string
}
variable "key_vault_id" {
  description = "key vault id of the key vault the secret is to be created in"
  type = string
}