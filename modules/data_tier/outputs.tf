output "lb_private_ip" {
  value = azurerm_lb.db_lb.frontend_ip_configuration[0].private_ip_address
}


output "data_lb_private_ip" {
  description = "The private IP address of the Data Tier Load Balancer."
  value       = module.data_tier.lb_private_ip
}

output "domain_join_script" {
  description = "The domain join script output from the Data Tier module."
  value       = module.data_tier.domain_join_script
}

