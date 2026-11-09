resource "azurerm_public_ip" "gateway" {
  name                = "${local.prefix}-gw-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${local.prefix}-${local.unique_suffix}"
  tags                = local.tags
}

locals {
  gw_backend_pool     = "app-backend"
  gw_http_settings    = "app-http-settings"
  gw_probe            = "app-health-probe"
  gw_frontend_ip      = "public-frontend"
  gw_frontend_port    = "http-80"
  gw_http_listener    = "http-listener"
  gw_routing_rule     = "http-to-app"
  gw_ip_configuration = "gateway-ip-config"
}

# Standard_v2 (no WAF), autoscale 1-2 instances.
resource "azurerm_application_gateway" "main" {
  name                = "${local.prefix}-agw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gw_ip_configuration
    subnet_id = azurerm_subnet.gateway.id
  }

  frontend_ip_configuration {
    name                 = local.gw_frontend_ip
    public_ip_address_id = azurerm_public_ip.gateway.id
  }

  frontend_port {
    name = local.gw_frontend_port
    port = 80
  }

  backend_address_pool {
    name  = local.gw_backend_pool
    fqdns = [azurerm_container_app.app.ingress[0].fqdn]
  }

  # Plain HTTP to the backend inside the VNet: the internal Container Apps
  # environment uses a default-domain certificate that is not publicly
  # trusted, so HTTPS validation from the gateway would fail. Traffic stays on
  # the private VNet; the app has no public endpoint.
  backend_http_settings {
    name                                = local.gw_http_settings
    protocol                            = "Http"
    port                                = 80
    cookie_based_affinity               = "Disabled"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = local.gw_probe
  }

  probe {
    name                                      = local.gw_probe
    protocol                                  = "Http"
    path                                      = var.health_check_path
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = local.gw_http_listener
    frontend_ip_configuration_name = local.gw_frontend_ip
    frontend_port_name             = local.gw_frontend_port
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.gw_routing_rule
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = local.gw_http_listener
    backend_address_pool_name  = local.gw_backend_pool
    backend_http_settings_name = local.gw_http_settings
  }

  # The gateway must resolve the app FQDN through the private zone.
  depends_on = [
    azurerm_private_dns_a_record.wildcard,
    azurerm_private_dns_a_record.root,
    azurerm_private_dns_zone_virtual_network_link.containerapps,
  ]
}

# Access, performance and metrics. The firewall log category exists only for
# WAF_v2, so it is intentionally not enabled on Standard_v2.
resource "azurerm_monitor_diagnostic_setting" "gateway" {
  name                       = "${local.prefix}-agw-diag"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
