output "name" {
  value = azurerm_resource_group.example.name
}



output "public_ip_address_id" {
    value = azurerm_public_ip.example[0].id
    description = "The ID of the public IP address."  
}