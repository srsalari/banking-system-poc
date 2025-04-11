# ./modules/network/variables.tf

variable "vnet_resource_group_name" {
  type        = string
  description = "Name of the resource group where the Virtual Network will be created."
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network."
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created."
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address space for the Virtual Network."
}

variable "AzureBastionSubnet_subnet_address_prefix" {
  type        = list(string)
  description = "Address prefix for the Bastion subnet."
}

variable "BusinessSubnet_subnet_address_prefix" {
  type        = list(string)
  description = "Address prefix for the Business Tier subnet."
}

variable "DataSubnet_subnet_address_prefix" {
  type        = list(string)
  description = "Address prefix for the Data Tier subnet."
}

variable "DMZSubnet_subnet_address_prefix" {
  type        = list(string)
  description = "Address prefix for the DMZ subnet."
}

variable "WebSubnet_subnet_address_prefix" {
  type        = list(string)
  description = "Address prefix for the Web Tier subnet."
}


