#
# Virtual Networks#

resource "azurerm_virtual_network" "vpc" {
  name                = "${var.vpc_name}-network"
  address_space       = [var.vpc_cidr]
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name
}

resource "azurerm_route_table" "vpc" {
  name                = "${var.vpc_name}-route-table"
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name
}

resource "azurerm_subnet" "dmz" {
  name                 = "${var.vpc_name}-dmz-subnet"
  resource_group_name  = azurerm_resource_group.bootstrap.name
  virtual_network_name = azurerm_virtual_network.vpc.name

  address_prefix = length(var.dmz_cidr) != 0 ? var.dmz_cidr : cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start)
}

resource "azurerm_subnet" "admin" {
  name                 = "${var.vpc_name}-admin-subnet"
  resource_group_name  = azurerm_resource_group.bootstrap.name
  virtual_network_name = azurerm_virtual_network.vpc.name

  address_prefix = length(var.admin_cidr) != 0 ? var.admin_cidr : (length(var.dmz_cidr) != 0 ? cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start) : cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start+1))
}
