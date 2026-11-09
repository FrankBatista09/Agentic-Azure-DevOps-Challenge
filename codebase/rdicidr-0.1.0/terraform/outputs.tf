output "acr_name" {
  value       = azurerm_container_registry.main.name
  description = "Name of the Azure Container Registry"
}

output "acr_login_server" {
  value       = azurerm_container_registry.main.login_server
  description = "ACR login server hostname"
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource group name"
}

output "app_fqdn" {
  value       = azurerm_container_app.app.ingress[0].fqdn
  description = "Internal FQDN of the container app (resolvable only inside the VNet)"
}

output "gateway_public_ip" {
  value       = azurerm_public_ip.gateway.ip_address
  description = "Public IP address of the Application Gateway"
}

output "gateway_fqdn" {
  value       = azurerm_public_ip.gateway.fqdn
  description = "DNS name of the Application Gateway public IP"
}

output "gateway_url" {
  value       = "http://${azurerm_public_ip.gateway.fqdn}"
  description = "Public URL of the application (through the Application Gateway)"
}

output "environment_name" {
  value       = azurerm_container_app_environment.main.name
  description = "Container App Environment name"
}
