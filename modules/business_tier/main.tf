# ./modules/business_tier/main.tf

//////////////////////////////
// 1. Resource Group
//////////////////////////////
resource "azurerm_resource_group" "business_rg" {
  name     = var.business_resource_group_name
  location = var.location
}

//////////////////////////////
// 2. Internal Load Balancer for Business Tier
//////////////////////////////
resource "azurerm_lb" "business_lb" {
  name                = var.business_lb_name
  location            = var.location
  resource_group_name = azurerm_resource_group.business_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "privateIPFrontendBusiness"
    subnet_id                     = var.business_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}
resource "azurerm_lb_backend_address_pool" "business_backend" {
  name            = "businessBackendPool"
  loadbalancer_id = azurerm_lb.business_lb.id
}


//////////////////////////////
// 3. LB Probe & LB Rule for Business LB
//////////////////////////////
resource "azurerm_lb_probe" "business_probe" {
  name                = "businessProbe"
  loadbalancer_id     = azurerm_lb.business_lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "business_app" {
  name                           = "businessAppRule"
  loadbalancer_id                = azurerm_lb.business_lb.id
  protocol                       = "Tcp"
  frontend_port                  = var.lb_frontend_port
  backend_port                   = var.lb_backend_port
  frontend_ip_configuration_name = "privateIPFrontendBusiness"
  backend_address_pool_ids       = [azurerm_lb.business_lb.backend_address_pool[0].id]
  probe_id                       = azurerm_lb_probe.business_probe.id
}

//////////////////////////////
// 4. Network Security Group and its Association
//////////////////////////////
resource "azurerm_network_security_group" "business_nsg" {
  name                = "business-tier-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.business_rg.name
}

resource "azurerm_subnet_network_security_group_association" "business_nsg_assoc" {
  subnet_id                 = var.business_subnet_id
  network_security_group_id = azurerm_network_security_group.business_nsg.id
}

resource "azurerm_network_security_rule" "allow_lb_inbound" {
  name                   = "AllowLBInbound"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = var.lb_backend_port
  // Allow traffic from the WEB tier subnet (assumed to be defined as CIDR in var.web_subnet_cidr)
  source_address_prefix = var.web_subnet_cidr
  // Use the business subnet CIDR as the destination prefix
  destination_address_prefix  = var.business_subnet_cidr
  resource_group_name         = azurerm_resource_group.business_rg.name
  network_security_group_name = azurerm_network_security_group.business_nsg.name
}

//////////////////////////////
// 5. Business Tier Virtual Machine Scale Set
//////////////////////////////
resource "azurerm_linux_virtual_machine_scale_set" "business_vmss" {
  name                = var.business_server_scale_set_name
  location            = var.location
  resource_group_name = azurerm_resource_group.business_rg.name
  sku                 = var.business_server_sku
  instances           = var.business_server_instance_count

  admin_username = var.admin_username_business
  admin_password = var.admin_password_business

  source_image_reference {
    publisher = var.business_server_image.publisher
    offer     = var.business_server_image.offer
    sku       = var.business_server_image.sku
    version   = var.business_server_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  upgrade_mode = "Automatic"

  network_interface {
    name    = "biz-nic"
    primary = true
    ip_configuration {
      name                                   = "internal"
      subnet_id                              = var.business_subnet_id
      primary                                = true
      load_balancer_backend_address_pool_ids = [azurerm_lb.business_lb.backend_address_pool[0].id]
    }
  }
}

//////////////////////////////
// 6. VM Extension on Business VMs: Forward traffic to Data Tier LB
//////////////////////////////
resource "azurerm_virtual_machine_extension" "business_forwarding" {
  count                = var.business_server_instance_count
  name                 = "business-forwarding-${count.index}"
  virtual_machine_id   = element(azurerm_linux_virtual_machine_scale_set.business_vmss.virtual_machine_ids, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
{
  "commandToExecute": "bash -c 'sysctl -w net.ipv4.ip_forward=1 && iptables -t nat -I PREROUTING -p tcp --dport 80 -j DNAT --to-destination ${var.data_lb_private_ip}:80 && iptables -t nat -I POSTROUTING -j MASQUERADE'"
}
SETTINGS
}




