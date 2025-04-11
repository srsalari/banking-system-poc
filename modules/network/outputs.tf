output "vnet_id" {
    description = "The ID of the Virtual Network."
    value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
    description = "Mapping of subnet names to their IDs."
    value = {
        AzureBastionSubnet = azurerm_subnet.AzureBastionSubnet.id
        BusinessSubnet     = azurerm_subnet.BusinessSubnet.id
        DataSubnet         = azurerm_subnet.DataSubnet.id
        DMZSubnet          = azurerm_subnet.DMZSubnet.id
        WebSubnet          = azurerm_subnet.WebSubnet.id
    }
}
