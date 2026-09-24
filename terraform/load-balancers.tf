resource "azurerm_public_ip" "application_gateway" {
  name                = "${local.name}-appgw-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = local.tags
}

resource "azurerm_application_gateway" "public" {
  name                = "${local.name}-appgw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip"
    subnet_id = azurerm_subnet.ingress.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  dynamic "frontend_port" {
    for_each = local.enable_https ? [1] : []

    content {
      name = "https"
      port = 443
    }
  }

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.application_gateway.id
  }

  dynamic "ssl_certificate" {
    for_each = local.enable_https ? [1] : []

    content {
      name     = var.application_gateway_certificate_name
      data     = filebase64(var.application_gateway_certificate_path)
      password = var.application_gateway_certificate_password
    }
  }

  backend_address_pool {
    name = "web"
  }

  backend_http_settings {
    name                  = "web-http"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30

    probe_name = "web-health"
  }

  probe {
    name                                      = "web-health"
    protocol                                  = "Http"
    path                                      = "/health"
    interval                                  = 30
    timeout                                   = 5
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    host                                      = "127.0.0.1"

    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "public"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  dynamic "http_listener" {
    for_each = local.enable_https ? [1] : []

    content {
      name                           = "https"
      frontend_ip_configuration_name = "public"
      frontend_port_name             = "https"
      protocol                       = "Https"
      ssl_certificate_name           = var.application_gateway_certificate_name
    }
  }

  request_routing_rule {
    name                       = "http-to-web"
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = "web"
    backend_http_settings_name = "web-http"
    priority                   = 100
  }

  dynamic "request_routing_rule" {
    for_each = local.enable_https ? [1] : []

    content {
      name                       = "https-to-web"
      rule_type                  = "Basic"
      http_listener_name         = "https"
      backend_address_pool_name  = "web"
      backend_http_settings_name = "web-http"
      priority                   = 110
    }
  }

  tags = local.tags
}

resource "azurerm_lb" "internal" {
  name                = "${local.name}-internal-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "app"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "app" {
  name            = "app"
  loadbalancer_id = azurerm_lb.internal.id
}

resource "azurerm_lb_probe" "app" {
  name            = "app-health"
  loadbalancer_id = azurerm_lb.internal.id
  protocol        = "Http"
  request_path    = "/health"
  port            = var.app_port
}

resource "azurerm_lb_rule" "app" {
  name                           = "app"
  loadbalancer_id                = azurerm_lb.internal.id
  protocol                       = "Tcp"
  frontend_port                  = var.app_port
  backend_port                   = var.app_port
  frontend_ip_configuration_name = "app"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.app.id
}
