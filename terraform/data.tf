data "azurerm_client_config" "current" {}

locals {
  name = "${var.project_name}-${var.environment}"

  ingress_subnet_cidr = cidrsubnet(var.vnet_cidr, 8, 0)
  web_subnet_cidr     = cidrsubnet(var.vnet_cidr, 8, 10)
  app_subnet_cidr     = cidrsubnet(var.vnet_cidr, 8, 20)
  db_subnet_cidr      = cidrsubnet(var.vnet_cidr, 8, 30)

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  enable_https = var.application_gateway_certificate_name != null && var.application_gateway_certificate_path != null
}
