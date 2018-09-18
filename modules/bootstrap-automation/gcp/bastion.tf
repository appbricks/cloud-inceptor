#
# Inception Bastion instance
#

resource "google_compute_instance" "bastion" {
  name         = "${var.vpc_name}-bastion"
  machine_type = "${var.bastion_instance_type}"
  zone         = "${data.google_compute_zones.available.names[0]}"

  allow_stopping_for_update = true

  tags = [
    "bastion-ssh",
    "bastion-vpn",
    "bastion-smtp",
    "bastion-proxy",
    "bastion-deny-vpc",
    "bastion-deny-dmz",
  ]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.bastion.self_link}"
      size  = "${var.bastion_root_disk_size}"
    }
  }

  attached_disk {
    source = "${google_compute_disk.bastion-data-volume.self_link}"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.dmz.self_link}"
    address    = "${google_compute_address.bastion-dmz.address}"

    access_config = [{
      nat_ip = "${google_compute_address.bastion-public.address}"

      # public_ptr_domain_name = "${google_dns_record_set.vpc-public.name}"
    }]
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.admin.self_link}"
    address    = "${google_compute_address.bastion-admin.address}"
  }

  metadata {
    ssh-keys           = "${var.bastion_admin_user}:${module.config.bastion_openssh_public_key}"
    user-data          = "${module.config.bastion_cloud_init_config}"
    user-data-encoding = "base64"
  }

  lifecycle {
    ignore_changes = ["metadata"]
  }
}

#
# Attached disk for saving persistant data. This disk needs to be
# large enough for any installation packages concourse downloads.
#

resource "google_compute_disk" "bastion-data-volume" {
  name = "${var.vpc_name}-bastion-data-volume"
  type = "pd-standard"
  zone = "${data.google_compute_zones.available.names[0]}"
  size = "${var.bastion_concourse_vols_disk_size}"
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

  subnetwork = "${google_compute_subnetwork.dmz.self_link}"
  region     = "${var.region}"

  address = "${cidrhost(google_compute_subnetwork.dmz.ip_cidr_range, -3)}"
}

resource "google_compute_address" "bastion-admin" {
  name         = "${var.vpc_name}-bastion-admin"
  address_type = "INTERNAL"

  subnetwork = "${google_compute_subnetwork.admin.self_link}"
  region     = "${var.region}"

  address = "${cidrhost(google_compute_subnetwork.admin.ip_cidr_range, -3)}"
}

resource "google_compute_address" "bastion-public" {
  name         = "${var.vpc_name}-bastion"
  address_type = "EXTERNAL"

  region = "${var.region}"
}

#
# Security (Firewall rules for the inception bastion instance)
#

resource "google_compute_firewall" "bastion-ssh" {
  count = "${var.bastion_allow_public_ssh == "true" ? 1 : 0 }"

  name    = "${var.vpc_name}-bastion-ssh"
  network = "${google_compute_network.dmz.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["${var.bastion_admin_ssh_port}"]
  }

  priority      = "500"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion-ssh"]
}

resource "google_compute_firewall" "bastion-vpn" {
  count = "${length(var.vpn_server_port) == 0 ? 0 : 1 }"

  name    = "${var.vpc_name}-bastion-vpn"
  network = "${google_compute_network.dmz.self_link}"

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

resource "google_compute_firewall" "bastion-smtp" {
  count = "${length(var.smtp_relay_host) == 0 ? 0 : 1 }"

  name    = "${var.vpc_name}-bastion-smtp"
  network = "${google_compute_network.dmz.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["25"]
  }

  priority      = "500"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion-smtp"]
}

resource "google_compute_firewall" "bastion-proxy" {
  count = "${length(var.squidproxy_server_port) == 0 ? 0 : 1 }"

  name    = "${var.vpc_name}-bastion-proxy"
  network = "${google_compute_network.admin.self_link}"

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
  network = "${google_compute_network.admin.self_link}"

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
  network = "${google_compute_network.dmz.self_link}"

  deny {
    protocol = "all"
  }

  priority      = "599"
  direction     = "INGRESS"
  source_ranges = ["${google_compute_subnetwork.dmz.ip_cidr_range}"]
  target_tags   = ["bastion-deny-dmz"]
}
