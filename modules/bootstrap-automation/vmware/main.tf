#
# VMWare IaaS references
#

data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_compute_cluster" "cl" {
  count = "${length(var.clusters)}"

  name          = "${element(var.clusters, count.index)}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "ds" {
  count = "${length(var.datastore) == 0 ? 0 : 1 }"

  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "dmz" {
  count = "${length(var.dmz_network) == 0 ? 0 : 1 }"

  name          = "${var.dmz_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "admin" {
  name          = "${var.admin_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "bastion-template" {
  name          = "/${var.datacenter}/vm/${var.bastion_template_path}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
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
