# One registry per environment. The CD pipeline bootstraps it with
# `terraform apply -target=azurerm_container_registry.main` before the first
# image push, so it must only depend on the resource group.
resource "azurerm_container_registry" "main" {
  name                = "acr${var.app_name}${var.environment}${local.unique_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "${local.prefix}-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# Only role assignment Terraform creates: least privilege image pull.
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
  principal_type       = "ServicePrincipal"
}
