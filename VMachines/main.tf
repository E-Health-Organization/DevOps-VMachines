data "azurerm_resource_group" "rg_existing" {
  name = "controlmachine_rg"
}

# resource "azurerm_public_ip" "public_ip" {
#     name = var.public_ip_name
#     resource_group_name = azurerm_resource_group.rg_existing.name
#     location = azurerm_resource_group.rg_existing.location
#     allocation_method = "Dynamic"
# }

resource "tls_private_key" "ssh_1" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "tls_private_key" "ssh_2" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "tls_private_key" "ssh_3" {
    algorithm = "RSA"
    rsa_bits = 4096
}

module "network" {
  source              = "./Modules/vnet"
  vnet_name           = "vnet"
  resource_group_name = data.azurerm_resource_group.rg_existing.name
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["AgentNet", "BackNet"]

  depends_on = [ data.azurerm_resource_group.rg_existing ]
}

module "nsg" {
  source              = "./Modules/nsg"
  nsg_name            = "Ehealth_NSG"
  resource_group_name = data.azurerm_resource_group.rg_existing.name
  location            = data.azurerm_resource_group.rg_existing.location
}

module "nic_agent" {
  source              = "./Modules/nic"
  nic_name            = "nic-agent"
  location            = data.azurerm_resource_group.rg_existing.location
  resource_group_name = data.azurerm_resource_group.rg_existing.name
  subnet_id           = module.network.subnet_ids["AgentNet"]
  # public_ip_address_id = azurerm_public_ip.public_ip.id
}

module "nic_back" {
  source              = "./Modules/nic"
  nic_name            = "nic-back"
  location            = data.azurerm_resource_group.rg_existing.location
  resource_group_name = data.azurerm_resource_group.rg_existing.name
  subnet_id           = module.network.subnet_ids["BackNet"]
}

# module "nic_mysql" {
#   source              = "./Modules/nic"
#   nic_name            = "nic-mysql"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id           = module.network.subnet_ids["BackMysqlNet"]
# }


module "vms" {
  source                = "./Modules/vms"
  vm_names             = ["Agent", "Backend"]
  resource_group_name  = data.azurerm_resource_group.rg_existing.name
  location             = data.azurerm_resource_group.rg_existing.location
  network_interface_ids = [module.nic_agent.nic_id, module.nic_back.nic_id]
  os_disk_names        = ["os_disk_vm1", "os_disk_vm2"]
  admin_username       = "azureuser"
  ssh_public_keys      = [tls_private_key.ssh_1.public_key_openssh, tls_private_key.ssh_2.public_key_openssh]
}

