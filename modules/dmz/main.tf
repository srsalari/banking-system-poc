// DMZ Module: This module defines an external load balancer that receives Internet traffic
// and distributes it to one or more NVA VMs. NVAs then forward requests to the internal Web tier.

//////////////////////////////
// 1. Resource Group
//////////////////////////////
resource "azurerm_resource_group" "dmz_rg" {
  name     = var.dmz_resource_group_name
  location = var.location
}

//////////////////////////////
// 2. Public IP for DMZ LB
//////////////////////////////
resource "azurerm_public_ip" "dmz_lb_public_ip" {
  name                = "${var.dmz_lb_name}-pip"
  location            = var.location
  resource_group_name = var.dmz_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

//////////////////////////////
// 3. External Load Balancer
//////////////////////////////
resource "azurerm_lb" "dmz_lb" {
  name                = var.dmz_lb_name
  location            = var.location
  resource_group_name = var.dmz_resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "publicIPFrontendDMZ"
    public_ip_address_id = azurerm_public_ip.dmz_lb_public_ip.id
    // Do not include a subnet_id when using a public IP reference.
  }


}

resource "azurerm_lb_backend_address_pool" "nva_backend" {
  count           = var.firewall_enabled ? 1 : 0
  name            = "nvaBackendPool"
  loadbalancer_id = azurerm_lb.dmz_lb.id
}

//////////////////////////////
// 4. LB Probe & Rule for NVA SSH (if firewall is enabled)
//////////////////////////////
resource "azurerm_lb_probe" "nva_lb_probe" {
  name                = "nvaProbe"
  loadbalancer_id     = azurerm_lb.dmz_lb.id
  protocol            = "Tcp"
  port                = 22
  interval_in_seconds = 15
  number_of_probes    = 2
}



resource "azurerm_lb_rule" "nva_ssh_rule" {
  count                          = var.firewall_enabled ? 1 : 0
  name                           = "nvaSSHRule"
  loadbalancer_id                = azurerm_lb.dmz_lb.id
  frontend_ip_configuration_name = "publicIPFrontendDMZ"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.nva_backend[0].id]
  frontend_port                  = 22
  backend_port                   = 22
  protocol                       = "Tcp"
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
  probe_id                       = azurerm_lb_probe.nva_lb_probe.id
}

//////////////////////////////
// 5. Network Security Group & NSG Rule
//////////////////////////////
resource "azurerm_network_security_group" "dmz_nsg" {
  name                = "dmz-nsg"
  location            = var.location
  resource_group_name = var.dmz_resource_group_name
}

resource "azurerm_network_security_rule" "allow_internet_inbound" {
  name                   = "AllowInternetInbound"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = var.db_lb_backend_port
  // Use a valid CIDR for the DMZ subnet
  destination_address_prefix  = var.DMZSubnet_subnet_address_prefix
  source_address_prefix       = "0.0.0.0/0" // Internet traffic
  resource_group_name         = var.dmz_resource_group_name
  network_security_group_name = azurerm_network_security_group.dmz_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "dmz_nsg_assoc" {
  subnet_id                 = var.dmz_subnet_id
  network_security_group_id = azurerm_network_security_group.dmz_nsg.id
}

//////////////////////////////
// 6. NVAs: Network Interfaces, then Virtual Machines
//////////////////////////////
resource "azurerm_network_interface" "nva_nic" {
  count               = var.nva_count
  name                = "nva-nic-${count.index}"
  location            = var.location
  resource_group_name = var.dmz_resource_group_name

  ip_configuration {
    name                          = "internal-${count.index}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.dmz_subnet_id
    // No public IP attached to the NVA NIC – LB handles the public exposure.
  }
}

resource "azurerm_virtual_machine" "nva_vm" {
  count               = var.nva_count
  name                = "nva-vm-${count.index}"
  location            = var.location
  resource_group_name = var.dmz_resource_group_name
  vm_size             = var.nva_vm_size
  network_interface_ids = [
    azurerm_network_interface.nva_nic[count.index].id
  ]

  storage_image_reference {
    publisher = var.nva_image.publisher
    offer     = var.nva_image.offer
    sku       = var.nva_image.sku
    version   = var.nva_image.version
  }

  storage_os_disk {
    create_option = "FromImage"
    name          = "osdisk-nva-${count.index}"
  }

  os_profile {
    computer_name  = "nva-${count.index}"
    admin_username = "azureuser-saeed" // Adjust as needed.
    admin_password = "Password123!***" // Use a secure method in production.
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "nva_forwarding" {
  count                = var.nva_count
  name                 = "nva-forwarding-${count.index}"
  virtual_machine_id   = azurerm_virtual_machine.nva_vm[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
{
  "commandToExecute": "bash -c 'sysctl -w net.ipv4.ip_forward=1 && iptables -t nat -I PREROUTING -p tcp --dport 80 -j DNAT --to-destination ${var.web_lb_private_ip}:80 && iptables -t nat -I POSTROUTING -j MASQUERADE'"
}
SETTINGS
}

//////////////////////////////
// 7. Output
//////////////////////////////
output "lb_public_ip" {
  description = "The public IP address of the DMZ load balancer"
  value       = azurerm_public_ip.dmz_lb_public_ip.ip_address
}


