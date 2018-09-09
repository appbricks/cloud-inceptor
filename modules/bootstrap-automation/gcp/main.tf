#
# Availability Zones in current region
#

data "google_compute_zones" "available" {
  region = "${var.region}"
}

#
# Standard Ubuntu image
#

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-1604-lts"
  project = "ubuntu-os-cloud"
}

#
# Default SSH Key Pair
#

resource "tls_private_key" "default-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "default-ssh-key" {
  content  = "${tls_private_key.default-ssh-key.private_key_pem}"
  filename = "${var.ssh_key_file_path}/default-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.ssh_key_file_path}/default-ssh-key.pem"
  }
}
