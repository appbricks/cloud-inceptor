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
}

resource "openstack_networking_network_v2" "main" {
  name           = var.vpc_name
  admin_state_up = true
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
  network_id      = openstack_networking_network_v2.main.id
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
  count = var.configure_admin_network ? 1 : 0

  router_id = openstack_networking_router_v2.main.id
  subnet_id = openstack_networking_subnet_v2.admin[0].id
}

# Route admin subnet traffic via bastion when acting as NAT gateway
resource "openstack_networking_router_route_v2" "admin_nat" {
  count = var.configure_admin_network && var.bastion_as_nat ? 1 : 0

  router_id        = openstack_networking_router_v2.main.id
  destination_cidr = "0.0.0.0/0"
  next_hop         = local.bastion_admin_itf_ip
}
