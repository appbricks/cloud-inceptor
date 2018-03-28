#
# Virtual Networks
#

resource "google_compute_network" "dmz" {
  name                    = "${var.vpc_name}-dmz-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dmz" {
  name = "${var.vpc_name}-dmz-subnet"

  ip_cidr_range = "${length(var.dmz_cidr) != 0 
    ? var.dmz_cidr 
    : cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start)}"

  network = "${google_compute_network.dmz.self_link}"
  region  = "${var.region}"
}

resource "google_compute_network" "mgmt" {
  name                    = "${var.vpc_name}-mgmt-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mgmt" {
  name = "${var.vpc_name}-mgmt-subnet"

  ip_cidr_range = "${length(var.dmz_cidr) != 0 
    ? cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start) 
    : cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, var.vpc_subnet_start + 1)}"

  network = "${google_compute_network.mgmt.self_link}"
  region  = "${var.region}"
}

#
# Firewall rules on DMZ Network
#

# Allow SSH from any external source
resource "google_compute_firewall" "dmz-allow-ext-ssh" {
  name    = "${var.vpc_name}-dmz-allow-ext-ssh"
  network = "${google_compute_network.dmz.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ext-ssh"]
}

# Allow SSH only from internal sources
resource "google_compute_firewall" "dmz-allow-int-ssh" {
  name    = "${var.vpc_name}-dmz-allow-int-ssh"
  network = "${google_compute_network.dmz.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["${var.vpc_cidr}"]
  target_tags   = ["allow-int-ssh"]
}

#
# Firewall rules on Engineering Network
#

# Allow all access from any source within the mgmt subnet.
# This assumes trust of all resources within the mgmt subnet
# and also removes the need to create an explicit rule to enable
# routing traffic from a private instance and NAT instances.
resource "google_compute_firewall" "mgmt-allow-all" {
  name    = "${var.vpc_name}-mgmt-allow-all"
  network = "${google_compute_network.mgmt.name}"

  allow {
    protocol = "all"
  }

  direction     = "INGRESS"
  source_ranges = ["${google_compute_subnetwork.mgmt.ip_cidr_range}"]
}

# Allow SSH from any external source
resource "google_compute_firewall" "mgmt-allow-ext-ssh" {
  name    = "${var.vpc_name}-mgmt-allow-ext-ssh"
  network = "${google_compute_network.mgmt.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ext-ssh"]
}

# Allow SSH only from internal sources
resource "google_compute_firewall" "mgmt-allow-int-ssh" {
  name    = "${var.vpc_name}-mgmt-allow-int-ssh"
  network = "${google_compute_network.mgmt.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["${var.vpc_cidr}"]
  target_tags   = ["allow-int-ssh"]
}
