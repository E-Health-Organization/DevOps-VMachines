output "vnet_name" {
  description = "The name of the virtual network"
  value       = data.azurerm_virtual_network.vnet_existant.name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = data.azurerm_virtual_network.vnet_existant.id
}

output "subnet_ids" {
  description = "A map of subnet names to their IDs"
  value       = local.azurerm_subnets
}
