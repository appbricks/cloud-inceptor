#
# Jumpbox
#

locals {
  local_dns = "${length(var.vpc_internal_dns_zones) > 0 
    ? element(var.vpc_internal_dns_zones, 0) : ""}"

  jumpbox_dns = "${var.deploy_jumpbox && length(local.local_dns) > 0 
    ? format("jumpbox.%s", local.local_dns) : ""}"

  jumpbox_dns_record = "${length(local.jumpbox_dns) > 0 
    ? format("%s:%s", local.jumpbox_dns, google_compute_address.jumpbox.address) : ""}"
}

resource "google_compute_instance" "jumpbox" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  name         = "${var.vpc_name}-jumpbox"
  machine_type = "f1-micro"
  zone         = data.google_compute_zones.available.names[0]

  allow_stopping_for_update = true

  tags = [
    "nat-${var.vpc_name}-${var.region}",
    "allow-int-ssh",
  ]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = "40"
    }
  }

  attached_disk {
    source = google_compute_disk.jumpbox-data[0].self_link
  }

  network_interface {
    subnetwork = google_compute_subnetwork.admin.self_link
    network_ip = google_compute_address.jumpbox.address
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.default-ssh-key.public_key_openssh}"

    user-data = <<USER_DATA
#cloud-config

write_files:
- encoding: b64
  content: ${base64encode(data.template_file.mount-jumpbox-data-volume.rendered)}
  path: /root/mount-volume.sh
  permissions: '0744'

runcmd: 
- sudo /root/mount-volume.sh
USER_DATA
  }
}

resource "google_compute_address" "jumpbox" {
  name         = "${var.vpc_name}-jumpbox"
  address_type = "INTERNAL"

  subnetwork = google_compute_subnetwork.admin.self_link
  region     = var.region
}

#
# Jumpbox data volume
#

data "template_file" "mount-jumpbox-data-volume" {
  template = file("${path.module}/scripts/mount-volume.sh")

  vars = {
    attached_device_name = "sdb"
    mount_directory      = "/data"
    world_readable       = "true"
  }
}

resource "google_compute_disk" "jumpbox-data" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  name = "${var.vpc_name}-jumpbox-data"
  type = "pd-standard"
  zone = data.google_compute_zones.available.names[0]
  size = var.jumpbox_data_disk_size
}
