data "azurerm_client_config" "current" {}

locals {
  prefix = "${var.app_name}-${var.environment}"

  # Short deterministic suffix for globally unique names, derived from the
  # subscription so no ID is hardcoded and devel/stage never collide.
  unique_suffix = substr(sha256("${data.azurerm_client_config.current.subscription_id}${var.app_name}${var.environment}"), 0, 6)

  tags = {
    app         = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}
