#
# VMWare IaaS references
#

locals {
  singleton_az          = "${var.availability_zones[element(keys(var.availability_zones), 0)]}"
  cluster_name          = "${local.singleton_az["cluster"]}"
  cluster_resource_pool = "${lookup(local.singleton_az, "resource_pool", "")}"

  num_networks = "${length(var.local_networks)}"
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

data "vsphere_network" "network" {
  count = "${local.num_networks}"

  name          = "${lookup(var.local_networks[count.index], "vsphere_network")}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
