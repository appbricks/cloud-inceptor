#
# Jumpbox
#

resource "google_compute_instance" "jumpbox" {
  name         = "${var.vpc_name}-jumpbox"
  machine_type = "f1-micro"
  zone         = "${data.google_compute_zones.available.names[0]}"

  tags = [
    "nat-${var.vpc_name}-${var.region}",
    "allow-int-ssh",
  ]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.ubuntu.self_link}"
      size  = "160"
    }
  }

  network_interface {
    subnetwork = "${data.google_compute_subnetwork.engineering.self_link}"
  }

  metadata {
    ssh-keys = "ubuntu:${tls_private_key.default-ssh-key.public_key_openssh} ubuntu"
  }
}

#
# Jumpbox DNS
#

resource "google_dns_record_set" "jumpbox" {
  name         = "jumpbox.${google_dns_managed_zone.vpc.dns_name}"
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${google_compute_instance.jumpbox.network_interface.0.address}"]
}

#
# Output
#

output "jumpbox-fqdn" {
  value = "${google_dns_record_set.jumpbox.name}"
}
