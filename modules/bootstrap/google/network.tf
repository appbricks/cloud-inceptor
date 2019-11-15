#
# Virtual Networks
#

resource "google_compute_network" "dmz" {
  name                    = "${var.vpc_name}-dmz-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dmz" {
  name = "${var.vpc_name}-dmz-subnet"

  ip_cidr_range = length(var.dmz_cidr) != 0 ? var.dmz_cidr : cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start)

  network = google_compute_network.dmz.self_link
  region  = var.region
}

resource "google_compute_network" "admin" {
  name                    = "${var.vpc_name}-admin-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "admin" {
  name = "${var.vpc_name}-admin-subnet"

  ip_cidr_range = length(var.admin_cidr) != 0 ? var.admin_cidr : (length(var.dmz_cidr) != 0 ? cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start) : cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start+1))

  network = google_compute_network.admin.self_link
  region  = var.region
}
