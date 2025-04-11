//////////////////////////////
// 1. Resource Group for Data Tier
//////////////////////////////
resource "azurerm_resource_group" "db_rg" {
  name     = var.db_resource_group_name
  location = var.location
}

//////////////////////////////
// 2. Internal Load Balancer for Data Tier
//////////////////////////////
resource "azurerm_lb" "db_lb" {
  name                = var.db_lb_name
  location            = var.location
  resource_group_name = azurerm_resource_group.db_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "privateIPFrontendData"
    subnet_id                     = var.db_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}


// External resource for lb backend address pool
resource "azurerm_lb_backend_address_pool" "db_backend_pool_external" {
  name            = "dataBackendPool"
  loadbalancer_id = azurerm_lb.db_lb.id
}

//////////////////////////////
// 3. Load Balancer Probe for SQL Traffic
//////////////////////////////
resource "azurerm_lb_probe" "sql_probe" {
  name                = "sqlProbe"
  loadbalancer_id     = azurerm_lb.db_lb.id
  protocol            = "Tcp"
  port                = var.db_lb_backend_port
  interval_in_seconds = 15
  number_of_probes    = 2
}

//////////////////////////////
// 4. Load Balancer Rule to Forward SQL Traffic
//////////////////////////////
resource "azurerm_lb_rule" "db_lb_rule" {
  name                           = "sqlTraffic"
  loadbalancer_id                = azurerm_lb.db_lb.id
  protocol                       = "Tcp"
  frontend_port                  = var.db_lb_frontend_port
  backend_port                   = var.db_lb_backend_port
  frontend_ip_configuration_name = "privateIPFrontendData"
  backend_address_pool_ids       = [azurerm_lb.db_lb.backend_address_pool[0].id]
  probe_id                       = azurerm_lb_probe.sql_probe.id
}

//////////////////////////////
// 5. Network Security Group for Data Tier and Association
//////////////////////////////
resource "azurerm_network_security_group" "db_nsg" {
  name                = "data-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.db_rg.name
}

resource "azurerm_subnet_network_security_group_association" "db_nsg_assoc" {
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

// (Optional) Additional NSG rules can be added here

//////////////////////////////
// 6. SQL Server Primary NIC and Virtual Machine
//////////////////////////////
resource "azurerm_network_interface" "sql_nic_primary" {
  name                = "sql-nic-primary"
  location            = var.location
  resource_group_name = azurerm_resource_group.db_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.db_subnet_id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_lb_backend_address_pool" "db_backend_pool" {
  name            = "dataBackendPool"
  loadbalancer_id = azurerm_lb.db_lb.id
}

resource "azurerm_virtual_machine" "sql_primary" {
  name                  = var.sql_server_primary_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.db_rg.name
  vm_size               = var.sql_server_vm_size
  network_interface_ids = [azurerm_network_interface.sql_nic_primary.id]

  storage_image_reference {
    publisher = var.sql_server_image.publisher
    offer     = var.sql_server_image.offer
    sku       = var.sql_server_image.sku
    version   = var.sql_server_image.version
  }

  storage_os_disk {
    create_option = "FromImage"
    name          = "osdisk-sql-primary"
  }

  os_profile {
    computer_name  = var.sql_server_primary_name
    admin_username = var.admin_username_db
    admin_password = var.admin_password_db
  }

  // Use os_profile_linux_config or os_profile_windows_config as needed.
}

//////////////////////////////
// 7. SQL Server Secondary NIC and Virtual Machine
//////////////////////////////
resource "azurerm_network_interface" "sql_nic_secondary" {
  name                = "sql-nic-secondary"
  location            = var.location
  resource_group_name = azurerm_resource_group.db_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.db_subnet_id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_network_interface_backend_address_pool_association" "sql_secondary_backend_association" {
  network_interface_id    = azurerm_network_interface.sql_nic_secondary.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.db_backend_pool.id
}

resource "azurerm_virtual_machine" "sql_secondary" {
  name                  = var.sql_server_secondary_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.db_rg.name
  vm_size               = var.sql_server_vm_size
  network_interface_ids = [azurerm_network_interface.sql_nic_secondary.id]

  storage_image_reference {
    publisher = var.sql_server_image.publisher
    offer     = var.sql_server_image.offer
    sku       = var.sql_server_image.sku
    version   = var.sql_server_image.version
  }

  storage_os_disk {
    create_option = "FromImage"
    name          = "osdisk-sql-secondary"
  }

  os_profile {
    computer_name  = var.sql_server_secondary_name
    admin_username = var.admin_username_db
    admin_password = var.admin_password_db
  }

  // Use os_profile_linux_config or os_profile_windows_config as needed.
}




