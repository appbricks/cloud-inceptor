#
# Virtual Networks
#

resource "google_compute_network" "dmz" {
  name                    = "${var.vpc_name}-dmz-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dmz" {
  name          = "${var.vpc_name}-dmz-subnet"
  ip_cidr_range = "${cidrsubnet(var.vpc_cidr, 8, var.subnet_start)}"
  network       = "${google_compute_network.dmz.self_link}"
}

resource "google_compute_network" "engineering" {
  name                    = "${var.vpc_name}-engineering-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "engineering" {
  name          = "${var.vpc_name}-engineering-subnet"
  ip_cidr_range = "${cidrsubnet(var.vpc_cidr, 8, var.subnet_start + 1)}"
  network       = "${google_compute_network.engineering.self_link}"
}

#
# Peer engineering and dmz networks
#

resource "google_compute_network_peering" "dmz" {
  name         = "${var.vpc_name}-dmz-engineering"
  network      = "${google_compute_network.dmz.self_link}"
  peer_network = "${google_compute_network.engineering.self_link}"
}

resource "google_compute_network_peering" "engineering" {
  name         = "${var.vpc_name}-engineering-dmz"
  network      = "${google_compute_network.engineering.self_link}"
  peer_network = "${google_compute_network.dmz.self_link}"
}

#
# Security (deny ingress from dmz to engineering)
#

resource "google_compute_firewall" "engineering-deny-dmz" {
  name    = "${var.vpc_name}-engineering-deny-dmz"
  network = "${google_compute_network.engineering.self_link}"

  deny {
    protocol = "all"
  }

  direction     = "INGRESS"
  source_ranges = ["${google_compute_subnetwork.dmz.ip_cidr_range}"]
}

#
# Outputs
#

output "dmz_network_name" {
  value = "${google_compute_network.dmz.name}"
}

output "dmz_subnetwork_name" {
  value = "${google_compute_subnetwork.dmz.name}"
}

output "engineering_network_name" {
  value = "${google_compute_network.engineering.name}"
}

output "engineering_subnetwork_name" {
  value = "${google_compute_subnetwork.engineering.name}"
}
