#
# VPC network, subnets and router
#

locals {
  dmz_cidr_block = (
    length(var.dmz_cidr) != 0
    ? var.dmz_cidr[0]
    : cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start)
  )
  admin_cidr_block = (
    length(var.admin_cidr) != 0
    ? var.admin_cidr[0]
    : (
      length(var.dmz_cidr) != 0
      ? cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start)
      : cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start + 1)
    )
  )
  admin_vlan_network = var.configure_admin_network && var.admin_vlan_id != 0
  admin_network_id = (
    local.admin_vlan_network
    ? openstack_networking_network_v2.admin[0].id
    : openstack_networking_network_v2.main.id
  )
}

resource "openstack_networking_network_v2" "main" {
  name           = var.vpc_name
  admin_state_up = true
}

resource "openstack_networking_network_v2" "admin" {
  count = local.admin_vlan_network ? 1 : 0

  name           = "${var.vpc_name}: admin"
  admin_state_up = true

  value_specs = {
    "provider:network_type"    = "vrack"
    "provider:segmentation_id" = var.admin_vlan_id
  }
}

resource "openstack_networking_subnet_v2" "dmz" {
  name            = "${var.vpc_name}: dmz subnet"
  network_id      = openstack_networking_network_v2.main.id
  cidr            = local.dmz_cidr_block
  ip_version      = 4
  dns_nameservers = []
}

resource "openstack_networking_subnet_v2" "admin" {
  count = var.configure_admin_network ? 1 : 0

  name            = "${var.vpc_name}: admin subnet"
  network_id      = local.admin_network_id
  cidr            = local.admin_cidr_block
  ip_version      = 4
  dns_nameservers = []
}

resource "openstack_networking_router_v2" "main" {
  name                = "${var.vpc_name}: router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "dmz" {
  router_id = openstack_networking_router_v2.main.id
  subnet_id = openstack_networking_subnet_v2.dmz.id
}

resource "openstack_networking_router_interface_v2" "admin" {
  # When bastion acts as NAT, admin is a private L2 behind the bastion (no router path).
  count = var.configure_admin_network && !var.bastion_as_nat ? 1 : 0

  router_id = openstack_networking_router_v2.main.id
  subnet_id = openstack_networking_subnet_v2.admin[0].id
}
