variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "servicenow-rg"
}

variable "location" {
  description = "The location of the resources"
  type        = string
  default     = "canadaeast"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "servicenow-vnet"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default = 1
}