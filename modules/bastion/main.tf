# ./modules/bastion/main.tf

//////////////////////////////
// 1. Resource Group for Bastion Tier
//////////////////////////////
resource "azurerm_resource_group" "bastion_rg" {
  name     = var.bastion_resource_group_name
  location = var.location
}

//////////////////////////////
// 2. Bastion Subnet (in the existing VNet)
//////////////////////////////
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"         // Must use this name
  resource_group_name  = var.vnet_resource_group_name // VNet’s resource group
  virtual_network_name = var.vnet_name
  address_prefixes     = var.bastion_subnet_address_prefixes
}

//////////////////////////////
// 3. Public IP for Bastion VM
//////////////////////////////
resource "azurerm_public_ip" "bastion_vm_public_ip" {
  name                = "${var.bastion_vm_name}-pip"
  location            = var.location
  resource_group_name = var.bastion_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

//////////////////////////////
// 4. Network Interface for Bastion VM
//////////////////////////////
resource "azurerm_network_interface" "bastion_vm_nic" {
  name                = "${var.bastion_vm_name}-nic"
  location            = var.location
  resource_group_name = var.bastion_resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bastion_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_vm_public_ip.id
  }
}

//////////////////////////////
// 5. Bastion VM (Jump Box)
//////////////////////////////
resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                = var.bastion_vm_name
  location            = var.location
  resource_group_name = var.bastion_resource_group_name
  size                = var.bastion_vm_size
  admin_username      = var.bastion_admin_username
  admin_password      = var.bastion_admin_password
  network_interface_ids = [
    azurerm_network_interface.bastion_vm_nic.id
  ]

  source_image_reference {
    publisher = var.bastion_image.publisher
    offer     = var.bastion_image.offer
    sku       = var.bastion_image.sku
    version   = var.bastion_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.bastion_vm_name}-osdisk"
  }

  computer_name                   = var.bastion_vm_name
  disable_password_authentication = false
}

//////////////////////////////
// 6. Outputs
//////////////////////////////
output "bastion_vm_public_ip" {
  description = "Public IP of the Bastion VM"
  value       = azurerm_public_ip.bastion_vm_public_ip.ip_address
}





