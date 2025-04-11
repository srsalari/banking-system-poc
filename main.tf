# main.tf (Root Module)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

//////////////////////////////
// Network Module
//////////////////////////////
module "network" {
  source                                   = "./modules/network"
  vnet_resource_group_name                 = var.vnet_resource_group_name
  vnet_name                                = var.vnet_name
  location                                 = var.location
  vnet_address_space                       = var.vnet_address_space
  AzureBastionSubnet_subnet_address_prefix = var.AzureBastionSubnet_subnet_address_prefix
  BusinessSubnet_subnet_address_prefix     = var.BusinessSubnet_subnet_address_prefix
  DataSubnet_subnet_address_prefix         = var.DataSubnet_subnet_address_prefix
  DMZSubnet_subnet_address_prefix          = var.DMZSubnet_subnet_address_prefix
  WebSubnet_subnet_address_prefix          = var.WebSubnet_subnet_address_prefix
}

//////////////////////////////
// DMZ Module
//////////////////////////////
module "dmz" {
  source                          = "./modules/dmz"
  dmz_resource_group_name         = var.dmz_resource_group_name
  location                        = var.location
  dmz_subnet_id                   = module.network.subnet_ids["DMZSubnet"]
  nva_count                       = var.dmz_nva_count       // number
  nva_vm_size                     = var.dmz_nva_vm_size     // string
  nva_image                       = var.dmz_nva_image       // object type
  firewall_enabled                = var.dmz_firewall_enabled // boolean
  allowed_cidrs_internet          = var.dmz_allowed_cidrs_internet
  dmz_lb_name                     = var.dmz_lb_name
  db_lb_backend_port              = var.db_lb_backend_port
  web_lb_private_ip               = var.web_lb_private_ip
  // Pass a string (first element) because the DMZ module expects a string:
  DMZSubnet_subnet_address_prefix = var.DMZSubnet_subnet_address_prefix[0]
}

//////////////////////////////
// Bastion Module
//////////////////////////////
module "bastion" {
  source                      = "./modules/bastion"
  bastion_resource_group_name = var.bastion_resource_group_name
  bastion_name                = var.bastion_name
  location                    = var.location

  // Provide required network details:
  vnet_name                = var.vnet_name
  vnet_resource_group_name = var.vnet_resource_group_name
  bastion_subnet_id        = module.network.subnet_ids["AzureBastionSubnet"]
  bastion_subnet_address_prefixes = var.AzureBastionSubnet_subnet_address_prefix

  bastion_vm_name        = var.bastion_vm_name
  bastion_vm_size        = var.bastion_vm_size
  bastion_admin_username = var.bastion_admin_username
  bastion_admin_password = var.bastion_admin_password
  bastion_image          = var.bastion_image
}

//////////////////////////////
// Web Tier Module
//////////////////////////////
module "web_tier" {
  source                    = "./modules/web_tier"
  location                  = var.location
  web_resource_group_name   = var.web_resource_group_name
  web_subnet_id             = module.network.subnet_ids["WebSubnet"]
  web_server_scale_set_name = var.web_server_scale_set_name
  web_server_sku            = var.web_server_sku
  web_server_image          = var.web_server_image
  web_server_instance_count = var.web_server_instance_count
  web_lb_name               = var.web_lb_name
  web_lb_backend_port       = var.web_lb_backend_port
  web_admin_username        = var.web_admin_username
  web_admin_password        = var.web_admin_password
}

//////////////////////////////
// Business Tier Module
//////////////////////////////
module "business_tier" {
  source                         = "./modules/business_tier"
  business_resource_group_name   = var.business_resource_group_name
  location                       = var.location
  business_subnet_id             = module.network.subnet_ids["BusinessSubnet"]
  business_server_scale_set_name = var.business_server_scale_set_name
  business_server_sku            = var.business_server_sku
  business_server_image          = var.business_server_image
  business_server_instance_count = var.business_server_instance_count
  business_lb_name               = var.business_lb_name
  lb_frontend_port               = var.lb_frontend_port
  lb_backend_port                = var.lb_backend_port

  # Additional required arguments:
  data_lb_private_ip      = var.data_lb_private_ip
  admin_username_business = var.admin_username_business
  admin_password_business = var.admin_password_business
  web_subnet_cidr         = var.web_subnet_cidr[0]
  business_subnet_cidr    = var.business_subnet_cidr[0]

  depends_on = [module.web_tier]
}

//////////////////////////////
// Data Tier Module
//////////////////////////////
module "data_tier" {
  source                    = "./modules/data_tier"
  db_resource_group_name    = var.db_resource_group_name
  location                  = var.location
  db_subnet_id              = module.network.subnet_ids["DataSubnet"]
  sql_server_primary_name   = var.sql_server_primary_name
  sql_server_secondary_name = var.sql_server_secondary_name
  sql_server_vm_size        = var.sql_server_vm_size
  sql_server_image          = var.sql_server_image
  db_lb_name                = var.db_lb_name
  db_lb_frontend_port       = var.db_lb_frontend_port
  db_lb_backend_port        = var.db_lb_backend_port
  domain_name               = var.domain_name

  # Additional required arguments:
  admin_username_db = var.admin_username_db
  admin_password_db = var.admin_password_db

  depends_on = [module.business_tier]
}





