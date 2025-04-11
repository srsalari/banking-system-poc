variable "business_resource_group_name" {
  description = "Resource group name for the Business Tier."
  type        = string
}

variable "location" {
  description = "Azure location for all resources."
  type        = string
}

variable "business_subnet_id" {
  description = "Subnet ID for the Business Tier."
  type        = string
}

variable "business_server_scale_set_name" {
  description = "Name for the Business Tier Virtual Machine Scale Set."
  type        = string
}

variable "business_server_sku" {
  description = "SKU for the Business Tier Virtual Machine Scale Set."
  type        = string
}

variable "web_subnet_cidr" {
  description = "CIDR block for the Web Tier subnet."
  type        = string
}

variable "business_subnet_cidr" {
  description = "The CIDR block of the Business Tier subnet."
  type        = string
}

variable "data_lb_private_ip" {
  description = "Private IP address of the Data Tier Load Balancer."
  type        = string
}

variable "admin_username_business" {
  description = "Admin username for the Business Tier VM Scale Set."
  type        = string
}

variable "admin_password_business" {
  description = "Admin password for the Business Tier VM Scale Set."
  type        = string
  sensitive   = true
}

variable "business_server_image" {
  description = "Image details for the Business Tier servers."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "business_server_instance_count" {
  description = "Number of instances for the Business Tier VM Scale Set."
  type        = number
}

variable "business_lb_name" {
  description = "Name for the Business Tier Load Balancer."
  type        = string
}

variable "lb_frontend_port" {
  description = "Frontend port for the Business LB rule."
  type        = number
}

variable "lb_backend_port" {
  description = "Backend port for the Business LB rule."
  type        = number
}
