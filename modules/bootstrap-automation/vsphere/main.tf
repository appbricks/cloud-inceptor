#
# VMWare IaaS references
#

locals {
  singleton_az          = "${var.availability_zones[element(keys(var.availability_zones), 0)]}"
  cluster_name          = "${local.singleton_az["cluster"]}"
  cluster_resource_pool = "${lookup(local.singleton_az, "resource_pool", "")}"
}

data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_resource_pool" "rp" {
  name          = "${join("/", list(local.cluster_name, "Resources", local.cluster_resource_pool))}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "eds" {
  name          = "${var.ephemeral_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "pds" {
  name          = "${var.persistent_datastore}"
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

data "vsphere_virtual_machine" "jumpbox-template" {
  count = "${length(var.deploy_jumpbox) > 0 ? 1 : 0}"

  name          = "/${var.datacenter}/vm/${var.jumpbox_template_path}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#
# VCenter folder for VPC
#

resource "vsphere_folder" "vpc" {
  path          = "${var.vpc_name}-bootstrap"
  type          = "vm"
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
