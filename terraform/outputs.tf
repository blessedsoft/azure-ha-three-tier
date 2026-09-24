output "application_gateway_public_ip" {
  description = "Public IP address for the Application Gateway."
  value       = azurerm_public_ip.application_gateway.ip_address
}

output "application_gateway_url" {
  description = "Public application URL."
  value       = local.enable_https ? "https://${azurerm_public_ip.application_gateway.ip_address}" : "http://${azurerm_public_ip.application_gateway.ip_address}"
}

output "internal_load_balancer_ip" {
  description = "Private frontend IP address for the internal application Load Balancer."
  value       = azurerm_lb.internal.private_ip_address
}

output "postgres_fqdn" {
  description = "Private PostgreSQL Flexible Server FQDN."
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "postgres_secret_id" {
  description = "Key Vault secret ID for the generated PostgreSQL administrator password."
  value       = azurerm_key_vault_secret.postgres_admin_password.id
  sensitive   = true
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = azurerm_key_vault.main.name
}

output "web_vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.web.name
}

output "app_vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.app.name
}
