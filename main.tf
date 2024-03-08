terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.94.0"
    }
  }

  cloud {
    organization = "maniakacademy"

    workspaces {
      name = "servicenow-terraform-azure"
    }
  }
}



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resourcename" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnetname" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}