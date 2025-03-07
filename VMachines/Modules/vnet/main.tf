data "azurerm_resource_group" "rg_existing" {
  name = "controlmachine_rg"
}

data "azurerm_virtual_network" "vnet_existing" {
  name = "vnet"
  resource_group_name = data.azurerm_resource_group.rg_existing.name
}

# resource "azurerm_virtual_network" "vnet" {
#   name                = var.vnet_name
#   resource_group_name = data.azurerm_resource_group.vnet_existing.name
#   location            = data.azurerm_resource_group.vnet_existing.location
#   address_space       = var.address_space
# }

# resource "azurerm_subnet" "subnet" {
#   count                = length(var.subnet_names)
#   name                 = var.subnet_names[count.index]
#   resource_group_name  = data.azurerm_resource_group.vnet_existing.name
#   virtual_network_name = data.azurerm_virtual_network.vnet_existing.name
#   address_prefixes     = [var.subnet_prefixes[count.index]]
# }

data "azurerm_virtual_network" "vnet_existant" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg_existing.name
  # location            = data.azurerm_resource_group.rg_existing.location
  # address_space       = var.address_space
}

resource "azurerm_subnet" "subnet" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = data.azurerm_resource_group.rg_existing.name
  virtual_network_name = data.azurerm_virtual_network.vnet_existing.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
}


locals {
  azurerm_subnets = {
    for index, subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }
}
