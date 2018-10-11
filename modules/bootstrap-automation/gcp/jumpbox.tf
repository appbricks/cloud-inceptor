#
# Jumpbox
#

resource "google_compute_instance" "jumpbox" {
  count = "${var.deploy_jumpbox == "true" ? 1 : 0}"

  name         = "${var.vpc_name}-jumpbox"
  machine_type = "f1-micro"
  zone         = "${data.google_compute_zones.available.names[0]}"

  allow_stopping_for_update = true

  tags = [
    "nat-${var.vpc_name}-${var.region}",
    "allow-int-ssh",
  ]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.ubuntu.self_link}"
      size  = "40"
    }
  }

  attached_disk {
    source = "${google_compute_disk.jumpbox-data-disk.self_link}"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.admin.self_link}"
  }

  metadata {
    ssh-keys = "ubuntu:${tls_private_key.default-ssh-key.public_key_openssh}"

    user-data = <<USER_DATA
#cloud-config

write_files:
- encoding: b64
  content: ${base64encode(data.template_file.mount-jumpbox-data-volume.rendered)}
  path: /root/mount-volume.sh
  permissions: '0744'

runcmd: 
- /root/mount-volume.sh
USER_DATA
  }
}

#
# Jumpbox data volume
#

data "template_file" "mount-jumpbox-data-volume" {
  template = "${file("${path.module}/scripts/mount-volume.sh")}"

  vars {
    attached_device_name = "/dev/sdb"
    mount_directory      = "/data"
    world_readable       = "true"
  }
}

resource "google_compute_disk" "jumpbox-data-disk" {
  count = "${var.deploy_jumpbox == "true" ? 1 : 0}"

  name = "${var.vpc_name}-jumpbox-data-disk"
  type = "pd-standard"
  zone = "${data.google_compute_zones.available.names[0]}"
  size = "${var.jumpbox_data_disk_size}"
}

#
# Jumpbox DNS
#

resource "google_dns_record_set" "jumpbox" {
  count = "${var.deploy_jumpbox == "true" ? 1 : 0}"

  name         = "jumpbox.${google_dns_managed_zone.vpc.dns_name}"
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${google_compute_instance.jumpbox.network_interface.0.network_ip}"]
}

#
# Output
#

output "jumpbox-fqdn" {
  value = "jumpbox.${google_dns_managed_zone.vpc.dns_name}"
}
