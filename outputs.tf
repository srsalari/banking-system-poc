output "vnet_id" {
  description = "The Virtual Network ID."
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "Mapping of subnet names to their IDs."
  value       = module.network.subnet_ids
}

output "dmz_lb_public_ip" {
  description = "The public IP address of the DMZ Load Balancer."
  value       = module.dmz.lb_public_ip
}

output "web_lb_private_ip" {
  description = "The private IP address of the Web Tier Load Balancer."
  value       = module.web_tier.lb_private_ip
}

output "business_lb_private_ip" {
  description = "The private IP address of the Business Tier Load Balancer."
  value       = module.business_tier.lb_private_ip
}

output "data_lb_private_ip" {
  description = "The private IP address of the Data Tier Load Balancer."
  value       = module.data_tier.lb_private_ip
}

output "domain_join_script" {
  description = "The domain join script output from the Data Tier module."
  value       = module.data_tier.domain_join_script
}