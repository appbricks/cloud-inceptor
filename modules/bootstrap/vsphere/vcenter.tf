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
  name          = "${join("/", tolist([local.cluster_name, "Resources", local.cluster_resource_pool]))}"
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

data "vsphere_host" "host" {
  count         = "${length(var.esxi_hosts)}"
  name          = "${var.esxi_hosts[count.index]}"
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
