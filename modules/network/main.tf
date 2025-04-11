# ./modules/network/main.tf:
resource "azurerm_resource_group" "vnet_rg" {
  name     = var.vnet_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.vnet_resource_group_name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.AzureBastionSubnet_subnet_address_prefix
}

resource "azurerm_subnet" "BusinessSubnet" {
  name                 = "BusinessSubnet"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.BusinessSubnet_subnet_address_prefix
}

resource "azurerm_subnet" "DataSubnet" {
  name                 = "DataSubnet"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.DataSubnet_subnet_address_prefix
}

resource "azurerm_subnet" "DMZSubnet" {
  name                 = "DMZSubnet"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.DMZSubnet_subnet_address_prefix
}

resource "azurerm_subnet" "WebSubnet" {
  name                 = "WebSubnet"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.WebSubnet_subnet_address_prefix
}




