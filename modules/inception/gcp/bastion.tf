#
# Inception Bastion VM
#

resource "google_compute_instance" "bastion" {
  name         = "${var.vpc_name}-bastion"
  machine_type = "${var.bastion_instance_type}"
  zone         = "${data.google_compute_zones.available.names[0]}"

  allow_stopping_for_update = true

  tags = [
    "bastion-vpn",
    "bastion-proxy",
    "bastion-deny-vpc",
    "bastion-deny-dmz",
  ]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.bastion.self_link}"
      size  = "160"
    }
  }

  network_interface {
    subnetwork = "${var.dmz_subnetwork}"
    address    = "${google_compute_address.bastion-dmz.address}"

    access_config = [{
      nat_ip = "${google_compute_address.bastion-public.address}"
    }]
  }

  network_interface {
    subnetwork = "${var.engineering_subnetwork}"
    address    = "${google_compute_address.bastion-engineering.address}"
  }

  metadata {
    ssh-keys           = "ubuntu:${module.config.bastion_openssh_public_key} ubuntu"
    user-data          = "${module.config.bastion_cloud_init_config}"
    user-data-encoding = "base64"
  }
}

#
# Image
#

data "google_compute_image" "bastion" {
  name = "${var.bastion_image_name}"
}

#
# Networking
#

resource "google_compute_address" "bastion-dmz" {
  name         = "${var.vpc_name}-bastion-dmz"
  address_type = "INTERNAL"

  subnetwork = "${var.dmz_subnetwork}"
  region     = "${var.region}"

  address = "${cidrhost(var.dmz_subnetwork_cidr, -3)}"
}

resource "google_compute_address" "bastion-engineering" {
  name         = "${var.vpc_name}-bastion-engineering"
  address_type = "INTERNAL"

  subnetwork = "${var.engineering_subnetwork}"
  region     = "${var.region}"

  address = "${cidrhost(var.engineering_subnetwork_cidr, -3)}"
}

resource "google_compute_address" "bastion-public" {
  name         = "${var.vpc_name}-bastion"
  address_type = "EXTERNAL"

  region = "${var.region}"
}

#
# Security (Firewall rules for the inception bastion instance)
#

resource "google_compute_firewall" "bastion-vpn" {
  name    = "${var.vpc_name}-bastion-vpn"
  network = "${var.dmz_network}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  allow {
    protocol = "${var.vpn_protocol}"
    ports    = ["${var.vpn_server_port}"]
  }

  priority      = "500"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion-vpn"]
}

resource "google_compute_firewall" "bastion-proxy" {
  name    = "${var.vpc_name}-bastion-proxy"
  network = "${var.engineering_network}"

  allow {
    protocol = "tcp"
    ports    = ["${var.squidproxy_server_port}"]
  }

  priority      = "500"
  direction     = "INGRESS"
  source_ranges = ["${var.vpn_network}", "${var.vpc_cidr}"]
  target_tags   = ["bastion-proxy"]
}

resource "google_compute_firewall" "bastion-deny-vpc" {
  name    = "${var.vpc_name}-bastion-deny-vpc"
  network = "${var.engineering_network}"

  deny {
    protocol = "all"
  }

  priority      = "599"
  direction     = "INGRESS"
  source_ranges = ["${var.vpc_cidr}"]
  target_tags   = ["bastion-deny-vpc"]
}

resource "google_compute_firewall" "bastion-deny-dmz" {
  name    = "${var.vpc_name}-bastion-deny-dmz"
  network = "${var.dmz_network}"

  deny {
    protocol = "all"
  }

  priority      = "599"
  direction     = "INGRESS"
  source_ranges = ["${var.dmz_subnetwork_cidr}"]
  target_tags   = ["bastion-deny-dmz"]
}
