variable "name" {
  description = "Name of VM"
  type = string
}
variable "admin_username" {
  description = "username of admin user"
  type = string
}
variable "network_interface_id" {
  description = "network interface id"
  type = list
}
variable "resource_group_name" {
  description = "Resource group name"
  type = string
}

variable "admin_password" {
  description = "admin password"
  type = string
}

variable "region" {
  description = "region"
  type = string
}