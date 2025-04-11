# ./modules/bastion/variables.tf
variable "bastion_resource_group_name" {
  description = "The name of the resource group for the Bastion tier."
  type        = string
}

variable "location" {
  description = "The Azure location for all resources."
  type        = string
}

variable "bastion_subnet_id" {
  description = "The subnet ID where the Bastion will be deployed."
  type        = string
}

variable "bastion_name" {
  description = "The name for the Bastion resources."
  type        = string
}

# Variables declarations for the Bastion module

variable "vnet_resource_group_name" {
  description = "The resource group name of the existing Virtual Network."
  type        = string
}

variable "vnet_name" {
  description = "The name of the existing Virtual Network."
  type        = string
}

variable "bastion_subnet_address_prefixes" {
  description = "The address prefixes for the Bastion subnet."
  type        = list(string)
}

variable "bastion_vm_name" {
  description = "The name for the Bastion VM resources."
  type        = string
  default     = "bastion-vm"
}

# Define variables for the Bastion module

variable "bastion_admin_password" {
  description = "The admin password for the Bastion VM."
  type        = string
  sensitive   = true
}

variable "bastion_admin_username" {
  description = "The admin username for the Bastion VM."
  type        = string
}

variable "bastion_vm_size" {
  description = "The size of the Bastion VM."
  type        = string
  default     = "Standard_B1s"
}

variable "bastion_image" {
  description = "The image details for the Bastion VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
variable "bastion_public_ip_name" {
  description = "The name for the public IP resource of the Bastion."
  type        = string
  default     = "bastion-ip"
}
variable "bastion_public_ip_sku" {
  description = "The SKU for the public IP resource of the Bastion."
  type        = string
  default     = "Standard"
}
variable "bastion_public_ip_allocation_method" {
  description = "The allocation method for the public IP resource of the Bastion."
  type        = string
  default     = "Static"
}
variable "bastion_public_ip_tier" {
  description = "The tier for the public IP resource of the Bastion."
  type        = string
  default     = "Regional"
}