// filepath: modules/business_tier/outputs.tf
output "lb_private_ip" {
  description = "The private IP address of the Business Tier Load Balancer."
  value       = azurerm_lb.business_lb.frontend_ip_configuration[0].private_ip_address
}
