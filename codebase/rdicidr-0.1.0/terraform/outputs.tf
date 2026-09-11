output "app_url" {
  value       = "https://${azurerm_container_app.app.ingress[0].fqdn}"
  description = "URL of the container app"
}

output "environment_name" {
  value       = azurerm_container_app_environment.main.name
  description = "Container App Environment name"
}
