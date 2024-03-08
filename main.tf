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
  location            = azurerm_resource_group.resourcename.location
  resource_group_name = azurerm_resource_group.resourcename.name
}


resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resourcename.name
  virtual_network_name = azurerm_virtual_network.vnetname.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  count               = var.vm_count
  name                = "example-nic-${count.index}"
  location            = azurerm_resource_group.resourcename.location
  resource_group_name = azurerm_resource_group.resourcename.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_linux_virtual_machine" "example" {
  count               = var.vm_count
  name                = "example-vm-${count.index}"
  resource_group_name = azurerm_resource_group.resourcename.name
  location            = azurerm_resource_group.resourcename.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  disable_password_authentication = true
  admin_password      = "ComplexPassword#1234"
  network_interface_ids = [
    element(azurerm_network_interface.example.*.id, count.index),
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}


resource "azurerm_virtual_machine_extension" "docker" {
  count                = var.vm_count
  name                 = "dockerExtension-${count.index}"
  virtual_machine_id   = azurerm_linux_virtual_machine.example[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get update && sudo apt-get install -y docker.io && sudo docker run -d -p 80:80 kennethreitz/httpbin"
    }
SETTINGS
}


resource "azurerm_public_ip" "example" {
  name                = "example-publicip"
  location            = azurerm_resource_group.resourcename.location
  resource_group_name = azurerm_resource_group.resourcename.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = "example-lb"
  location            = azurerm_resource_group.resourcename.location
  resource_group_name = azurerm_resource_group.resourcename.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}


resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "example-bepool"
}

# Health probe to check the availability of HTTP service
resource "azurerm_lb_probe" "example" {
  loadbalancer_id     = azurerm_lb.example.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

# Load balancer rule for HTTP traffic
resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.example.id
}

# Network Interface updated to associate with the LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.example[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}