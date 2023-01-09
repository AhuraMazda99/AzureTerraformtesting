variable "region" {
  description = "azure region"
  type        = string
  default     = "Central US"
}

variable "ip_rang" {
description = "ip range for network"
type = string
default = "10.50.0.0/16"
}

variable "subnet1" {
description = "subnet range for network"
type = string
default = "10.50.20.0/16"
}

variable "subnet2" {
description = "subnet range for network"
type = string
default = "10.50.22.0/16"
}