resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = "${local.name}-web-vmss"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.web_vm_size
  instances           = var.web_instance_count
  admin_username      = var.admin_username
  zones               = ["1", "2"]

  disable_password_authentication = true
  overprovision                   = false
  upgrade_mode                    = "Rolling"

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vm.id]
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "web-nic"
    primary = true

    ip_configuration {
      name                                         = "web"
      primary                                      = true
      subnet_id                                    = azurerm_subnet.web.id
      application_gateway_backend_address_pool_ids = [one(azurerm_application_gateway.public.backend_address_pool).id]
    }
  }

  custom_data = base64encode(templatefile("${path.module}/user-data/web.sh", {
    app_internal_ip = azurerm_lb.internal.private_ip_address
    app_port        = var.app_port
  }))

  tags = merge(local.tags, {
    Tier = "web"
  })
}

resource "azurerm_linux_virtual_machine_scale_set" "app" {
  name                = "${local.name}-app-vmss"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.app_vm_size
  instances           = var.app_instance_count
  admin_username      = var.admin_username
  zones               = ["1", "2"]

  disable_password_authentication = true
  overprovision                   = false
  upgrade_mode                    = "Rolling"

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vm.id]
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "app-nic"
    primary = true

    ip_configuration {
      name                                   = "app"
      primary                                = true
      subnet_id                              = azurerm_subnet.app.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app.id]
    }
  }

  custom_data = base64encode(templatefile("${path.module}/user-data/app.sh", {
    app_port       = var.app_port
    db_host        = azurerm_postgresql_flexible_server.postgres.fqdn
    db_name        = var.db_name
    db_username    = var.db_username
    key_vault_name = azurerm_key_vault.main.name
    db_secret_name = azurerm_key_vault_secret.postgres_admin_password.name
  }))

  tags = merge(local.tags, {
    Tier = "app"
  })
}
