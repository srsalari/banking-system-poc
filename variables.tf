// Global Settings
variable "location" {
  description = "Azure region where resources will be created."
  type        = string
  default     = "Canada Central"
}



// Virtual Network Settings
variable "vnet_resource_group_name" {
  description = "Resource group for the Virtual Network."
  type        = string
  default     = "vnet-rg"
}

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
  default     = "app-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

// Subnet Address Prefixes
variable "AzureBastionSubnet_subnet_address_prefix" {
  description = "Address prefix for the Bastion subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "BusinessSubnet_subnet_address_prefix" {
  description = "Address prefix for the Business tier subnet."
  type        = list(string)
  default     = ["10.0.4.0/24"]
}

variable "DataSubnet_subnet_address_prefix" {
  description = "Address prefix for the Data tier subnet."
  type        = list(string)
  default     = ["10.0.5.0/24"]
}

variable "DMZSubnet_subnet_address_prefix" {
  description = "Address prefix for the DMZ subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "WebSubnet_subnet_address_prefix" {
  description = "Address prefix for the Web tier subnet."
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

// Bastion Tier Parameters

variable "bastion_resource_group_name" {
  description = "Resource group for the Bastion tier."
  type        = string
  default     = "bastion-rg"
}
variable "bastion_subnet_id" {
  description = "Subnet ID for Bastion (from network module output)."
  type        = string
  default     = "AzureBastionSubnet-id"
}

variable "bastion_name" {
  description = "Name prefix for Bastion resources."
  type        = string
  default     = "bastionhost"
}

variable "bastion_vm_name" {
  description = "Name for the Bastion VM."
  type        = string
  default     = "bastionvm"
}

variable "bastion_vm_size" {
  description = "VM size for the Bastion VM."
  type        = string
  default     = "Standard_B2s"
}

variable "bastion_admin_username" {
  description = "Admin username for the Bastion VM."
  type        = string
  default     = "bastionadmineuser"
}

variable "bastion_admin_password" {
  description = "Admin password for the Bastion VM."
  type        = string
  default     = "Password123!"
}

variable "bastion_image" {
  description = "Image details for the Bastion VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

// Business Tier Parameters

variable "business_resource_group_name" {
  description = "Resource group name for Business tier."
  type        = string
  default     = "business-rg"
}
variable "admin_username_business" {
  description = "Admin username for Business tier scale set."
  type        = string
  default     = "bizadmin"
}

variable "admin_password_business" {
  description = "Admin password for Business tier scale set."
  type        = string
  default     = "BizPassword123!"
}

variable "business_subnet_id" {
  description = "Subnet ID for Business tier (from network module output)."
  type        = string
  default     = "BusinessSubnet-id"
}

variable "business_server_scale_set_name" {
  description = "Name for the Business tier VM scale set."
  type        = string
  default     = "businessserver-vmss"
}

variable "business_server_sku" {
  description = "SKU for the Business tier VM scale set."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "business_server_image" {
  description = "Image details for the Business tier servers."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "business_server_instance_count" {
  description = "Number of instances in the Business tier VM scale set."
  type        = number
  default     = 2
}

variable "business_lb_name" {
  description = "Name for the Business tier Load Balancer."
  type        = string
  default     = "business-lb"
}

variable "lb_frontend_port" {
  description = "Frontend port for the Business LB rule."
  type        = number
  default     = 3000
}

variable "lb_backend_port" {
  description = "Backend port for the Business LB rule."
  type        = number
  default     = 3000
}

// Data Tier Parameters
variable "db_resource_group_name" {
  description = "Resource group name for Data tier."
  type        = string
  default     = "data-rg"
}

variable "admin_username_db" {
  description = "Admin username for the SQL server VMs."
  type        = string
  default     = "sqladmin"
}

variable "admin_password_db" {
  description = "Admin password for the SQL server VMs."
  type        = string
  default     = "SqlPassword123!"
  # sensitive   = true
}

variable "db_subnet_id" {
  description = "Subnet ID for Data tier (from network module output)."
  type        = string
  default     = "DataSubnet-id"
}

variable "sql_server_primary_name" {
  description = "Primary SQL server name."
  type        = string
  default     = "sqlprimary"
}

variable "sql_server_secondary_name" {
  description = "Secondary SQL server name."
  type        = string
  default     = "sqlsecondary"
}

variable "sql_server_vm_size" {
  description = "VM size for SQL servers."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "sql_server_image" {
  description = "Image details for the SQL servers."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftSQLServer"
    offer     = "SQLServer2019-WS2019"
    sku       = "Standard"
    version   = "latest"
  }
}

variable "db_lb_name" {
  description = "Name for the Data tier Load Balancer."
  type        = string
  default     = "sqllb"
}

variable "db_lb_frontend_port" {
  description = "Frontend port for the Data LB."
  type        = number
  default     = 1433
}

variable "db_lb_backend_port" {
  description = "Backend port for the Data LB."
  type        = number
  default     = 1433
}

variable "domain_name" {
  description = "Domain name used for Data tier VMs."
  type        = string
  default     = "example.com"
}

// DMZ Tier Parameters
variable "dmz_resource_group_name" {
  description = "Resource group for DMZ tier."
  type        = string
  default     = "dmz-rg"
}

variable "web_lb_private_ip" {
  description = "Private IP address for the Web Load Balancer."
  type        = string
  default     = "10.0.3.5"
}

variable "dmz_subnet_id" {
  description = "Subnet ID for DMZ tier (from network module output)."
  type        = string
  default     = "DMZSubnet-id"
}

variable "dmz_nva_count" {
  description = "Number of NVA instances in the DMZ."
  type        = number
  default     = 2
}

variable "dmz_nva_vm_size" {
  description = "VM size for DMZ NVA instances."
  type        = string
  default     = "Standard_B2ms"
}

variable "dmz_nva_image" {
  description = "Image details for DMZ NVA instances."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "dmz_lb_name" {
  description = "Name for the DMZ Load Balancer."
  type        = string
  default     = "dmz-lb"
}

variable "firewall_enabled" {
  description = "Enable or disable firewall rules in DMZ."
  type        = bool
  default     = false
}

variable "dmz_allowed_cidrs_internet" {
  description = "Allowed CIDR blocks for DMZ internet access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

// Web Tier Parameters
variable "web_lb_backend_port" {
  description = "Backend port for Web tier Load Balancer."
  type        = number
  default     = 80
}

variable "web_server_sku" {
  description = "SKU for Web tier servers."
  type        = string
  default     = "Standard_B2ms"
}

variable "web_server_image" {
  description = "Image details for Web tier servers."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "dmz_firewall_enabled" {
  description = "Whether DMZ firewall rules are enabled."
  type        = bool
  default     = false
}

// --- For Web Tier Module ---
variable "web_resource_group_name" {
  description = "Resource group for the Web tier."
  type        = string
  default     = "web-rg"
}

variable "web_server_scale_set_name" {
  description = "Name for the Web Tier VM scale set."
  type        = string
  default     = "web-vmss"
}

variable "web_lb_name" {
  description = "Name for the Web Tier Load Balancer."
  type        = string
  default     = "web-lb"
}

variable "web_server_instance_count" {
  description = "Instance count for Web tier VM scale set."
  type        = number
  default     = 2
}

variable "web_admin_username" {
  type    = string
  default = "webadmin"
}

variable "web_admin_password" {
  type    = string
  default = "WebPassword123!"
}



variable "data_lb_private_ip" {
  description = "Private IP address for the data load balancer"
  type        = string
}
