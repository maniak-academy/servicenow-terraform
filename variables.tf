variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
  default = "canadaeast"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default = "servicenow-vnet"
}
