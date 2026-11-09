# Internal, VNet-integrated environment: the app has no public endpoint and is
# reachable only through the Application Gateway.
resource "azurerm_container_app_environment" "main" {
  name                           = "${local.prefix}-env"
  location                       = azurerm_resource_group.main.location
  resource_group_name            = azurerm_resource_group.main.name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id       = azurerm_subnet.containerapps.id
  internal_load_balancer_enabled = true
  zone_redundancy_enabled        = false
  tags                           = local.tags

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "azurerm_container_app" "app" {
  name                         = local.prefix
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  # external_enabled = true on an INTERNAL environment means "reachable inside
  # the VNet via the internal load balancer", not from the internet.
  #
  # allow_insecure_connections = true lets the gateway reach the app over plain
  # HTTP on port 80 inside the VNet. The default-domain certificate of an
  # internal environment is not publicly trusted, so HTTPS from the gateway
  # would fail validation. Trade-off: gateway-to-app traffic is unencrypted,
  # but it never leaves the private VNet. The public listener is HTTP only for
  # now; add a certificate to the gateway to serve HTTPS to clients.
  ingress {
    target_port                = var.container_port
    external_enabled           = true
    allow_insecure_connections = true
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.app_name
      image  = "${azurerm_container_registry.main.login_server}/${var.image_repository}:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      startup_probe {
        transport               = "HTTP"
        port                    = var.container_port
        path                    = var.health_check_path
        interval_seconds        = 5
        timeout                 = 3
        failure_count_threshold = 30
      }

      liveness_probe {
        transport               = "HTTP"
        port                    = var.container_port
        path                    = var.health_check_path
        interval_seconds        = 10
        timeout                 = 3
        failure_count_threshold = 3
      }

      readiness_probe {
        transport               = "HTTP"
        port                    = var.container_port
        path                    = var.health_check_path
        interval_seconds        = 10
        timeout                 = 3
        failure_count_threshold = 3
        success_count_threshold = 1
      }
    }
  }

  # The image pull needs AcrPull to exist first.
  depends_on = [azurerm_role_assignment.acr_pull]
}
