variable "dmz_resource_group_name" {
  description = "Resource group name for the DMZ Tier."
  type        = string
}

variable "location" {
  description = "Azure location for all resources."
  type        = string
}

variable "dmz_subnet_id" {
  description = "Subnet ID for the DMZ Tier."
  type        = string
}

variable "nva_count" {
  description = "Number of NVA instances."
  type        = number
}

variable "nva_vm_size" {
  description = "The VM size for the NVA VMs."
  type        = string
}

variable "nva_image" {
  description = "Image details for the NVA VMs."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "dmz_lb_name" {
  description = "Name for the DMZ Load Balancer."
  type        = string
}

variable "firewall_enabled" {
  description = "Flag to enable firewall rules."
  type        = bool
}

variable "allowed_cidrs_internet" {
  description = "List of allowed CIDR blocks for internet access."
  type        = list(string)
}

variable "db_lb_backend_port" {
  description = "Backend port number for the DMZ LB rule."
  type        = number
}

variable "web_lb_private_ip" {
  description = "Private IP address for the Web Load Balancer."
  type        = string
}

variable "DMZSubnet_subnet_address_prefix" {
  description = "CIDR for the DMZ subnet."
  type        = string
}
