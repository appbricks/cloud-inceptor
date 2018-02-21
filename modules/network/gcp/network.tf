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

# Allow all access from any source within the engineering subnet.
# This assumes trust of all resources within the engineering subnet
# and also removes the need to create an explicit rule to enable
# routing traffic from a private instance and NAT instances.
resource "google_compute_firewall" "engineering-allow-all" {
  name    = "${var.vpc_name}-engineering-allow-all"
  network = "${google_compute_network.engineering.name}"

  allow {
    protocol = "all"
  }

  direction     = "INGRESS"
  source_ranges = ["${google_compute_subnetwork.engineering.ip_cidr_range}"]
}

# Allow SSH from any external source
resource "google_compute_firewall" "engineering-allow-ext-ssh" {
  name    = "${var.vpc_name}-engineering-allow-ext-ssh"
  network = "${google_compute_network.engineering.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ext-ssh"]
}

# Allow SSH only from internal sources
resource "google_compute_firewall" "engineering-allow-int-ssh" {
  name    = "${var.vpc_name}-engineering-allow-int-ssh"
  network = "${google_compute_network.engineering.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["${var.vpc_cidr}"]
  target_tags   = ["allow-int-ssh"]
}
