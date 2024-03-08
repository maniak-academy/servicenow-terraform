output "name" {
  value = azurerm_resource_group.resourcename.name
}

output "load_balancer_public_ip" {
  value = azurerm_public_ip.example.ip_address
  description = "The public IP address of the load balancer."
}
