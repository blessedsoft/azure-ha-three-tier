provider "azurerm" {
  features {}

  subscription_id = var.subscription_id

  resource_provider_registrations = "none"
}

resource "azurerm_resource_group" "main" {
  name     = "${local.name}-rg"
  location = var.location

  tags = local.tags
}
