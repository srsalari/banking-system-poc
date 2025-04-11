# **3. `./modules/web_tier/main.tf`:**

//////////////////////////////
// 1. Resource Group
//////////////////////////////
resource "azurerm_resource_group" "web_rg" {
  name     = var.web_resource_group_name
  location = var.location
}

//////////////////////////////
// 2. Internal Load Balancer for Web Tier
//////////////////////////////
resource "azurerm_lb" "web_lb" {
  name                = var.web_lb_name
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = var.web_resource_group_name
  sku                 = "Basic" // use "Standard" if needed

  frontend_ip_configuration {
    // Internal LB: Use a private frontend configuration from the web subnet
    name                          = "internalFrontendWeb"
    subnet_id                     = var.web_subnet_id
    private_ip_address_allocation = "Dynamic"
  }


}

resource "azurerm_lb_backend_address_pool" "web_backend_pool" {
  name                = "webBackendPool"
  loadbalancer_id     = azurerm_lb.web_lb.id
}


//////////////////////////////
// 3. LB Probe & Rule for HTTP Traffic
//////////////////////////////
resource "azurerm_lb_probe" "web_probe" {
  name                = "webProbe"
  loadbalancer_id     = azurerm_lb.web_lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "web_http_rule" {
  name                           = "webHTTPRule"
  loadbalancer_id                = azurerm_lb.web_lb.id
  frontend_ip_configuration_name = "internalFrontendWeb"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_backend_pool.id]
  frontend_port                  = 80
  backend_port                   = 80
  protocol                       = "Tcp"
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
  probe_id                       = azurerm_lb_probe.web_probe.id
}

//////////////////////////////
// 4. Network Security: NSG & Association
//////////////////////////////
resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = var.web_resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "web_nsg_assoc" {
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

//////////////////////////////
// 5. Web Server Virtual Machine Scale Set
//////////////////////////////
resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = var.web_server_scale_set_name
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name
  sku                 = var.web_server_sku
  instances           = var.web_server_instance_count

  admin_username = var.web_admin_username
  admin_password = var.web_admin_password

  source_image_reference {
    publisher = var.web_server_image.publisher
    offer     = var.web_server_image.offer
    sku       = var.web_server_image.sku
    version   = var.web_server_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  upgrade_mode = "Automatic"

  network_interface {
    name    = "web-nic"
    primary = true
    ip_configuration {
      name                                   = "internal"
      subnet_id                              = var.web_subnet_id
      primary                                = true
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_backend_pool.id]
    }
  }
}

//////////////////////////////
// 6. Autoscale Setting for VMSS
//////////////////////////////
resource "azurerm_monitor_autoscale_setting" "web_vmss_autoscale" {
  name                = "${var.web_server_scale_set_name}-autoscale"
  resource_group_name = var.web_resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web_vmss.id

  profile {
    name = "defaultProfile"
    capacity {
      minimum = "1"
      maximum = "10"
      default = var.web_server_instance_count
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}

//////////////////////////////
// 7. Output
//////////////////////////////
output "lb_private_ip" {
  value       = azurerm_lb.web_lb.frontend_ip_configuration[0].private_ip_address
  description = "The private IP address of the internal Web Load Balancer."
}
