# **`./modules/data_tier/variables.tf`:**

variable "db_resource_group_name" {
  description = "Resource group name for the Data Tier."
  type        = string
}

variable "admin_username_db" {
  description = "Admin username for the SQL server VMs."
  type        = string
}

variable "admin_password_db" {
  description = "Admin password for the SQL server VMs."
  type        = string
  # sensitive   = true
}

variable "location" {
  description = "Azure location for all resources."
  type        = string
}

variable "db_subnet_id" {
  description = "Subnet ID for the Data Tier."
  type        = string
}

variable "sql_server_primary_name" {
  description = "The name of the primary SQL server."
  type        = string
}

variable "sql_server_secondary_name" {
  description = "The name of the secondary SQL server."
  type        = string
}

variable "sql_server_vm_size" {
  description = "The VM size for the SQL servers."
  type        = string
}

variable "sql_server_image" {
  description = "Details of the image to use for the SQL server VMs."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "db_lb_name" {
  description = "Name for the Data Tier Load Balancer."
  type        = string
}

variable "db_lb_frontend_port" {
  description = "Frontend port for the Data Tier LB."
  type        = number
}

variable "db_lb_backend_port" {
  description = "Backend port for the Data Tier LB."
  type        = number
}

variable "domain_name" {
  description = "Domain name for the Data Tier VMs."
  type        = string
}
