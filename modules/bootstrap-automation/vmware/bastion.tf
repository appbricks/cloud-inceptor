#
# Inception Bastion instance
#

resource "vsphere_virtual_machine" "bastion-1nic" {
  count = "${length(var.dmz_network) == 0 ? 1 : 0 }"

  name = "${element(split(".", var.vpc_dns_zone), 0)}"

  resource_pool_id = "${data.vsphere_compute_cluster.cl.*.resource_pool_id[0]}"
  datastore_id     = "${data.vsphere_datastore.ds.id}"

  memory   = "${var.bastion_instance_memory}"
  num_cpus = "${var.bastion_instance_cpus}"

  guest_id  = "${data.vsphere_virtual_machine.bastion-template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.bastion-template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.admin.id}"
    adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.bastion-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bastion-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bastion-template.disks.0.thin_provisioned}"
  }

  disk {
    label = "disk1"
    size  = "${vsphere_virtual_disk.data.size}"
    path  = "${vsphere_virtual_disk.data.vmdk_path}"

    unit_number = 14
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.bastion-template.id}"
  }

  extra_config {
    guestinfo.userdata          = "${module.config.bastion_cloud_init_config}"
    guestinfo.userdata.encoding = "gzip+base64"
  }

  wait_for_guest_net_timeout  = -1
  wait_for_guest_net_routable = false
}

resource "vsphere_virtual_machine" "bastion-2nic" {
  count = "${length(var.dmz_network) > 0 ? 1 : 0 }"

  name = "${element(split(".", var.vpc_dns_zone), 0)}"

  resource_pool_id = "${data.vsphere_compute_cluster.cl.*.resource_pool_id[0]}"
  datastore_id     = "${data.vsphere_datastore.ds.id}"

  memory   = "${var.bastion_instance_memory}"
  num_cpus = "${var.bastion_instance_cpus}"

  guest_id              = "${data.vsphere_virtual_machine.bastion-template.guest_id}"
  scsi_type             = "${data.vsphere_virtual_machine.bastion-template.scsi_type}"
  scsi_controller_count = 2

  network_interface {
    network_id   = "${data.vsphere_network.dmz.id}"
    adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.admin.id}"
    adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.bastion-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bastion-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bastion-template.disks.0.thin_provisioned}"
  }

  disk {
    label = "disk1"
    size  = "${vsphere_virtual_disk.data.size}"
    path  = "${vsphere_virtual_disk.data.vmdk_path}"

    unit_number = 14
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.bastion-template.id}"
  }

  extra_config {
    guestinfo.userdata          = "${module.config.bastion_cloud_init_config}"
    guestinfo.userdata.encoding = "gzip+base64"
  }

  wait_for_guest_net_timeout  = -1
  wait_for_guest_net_routable = false
}

#
# Bastion data volume
#

resource "vsphere_virtual_disk" "data" {
  size               = "${var.bastion_data_disk_size}"
  vmdk_path          = "/bastion/data.vmdk"
  datacenter         = "${data.vsphere_datacenter.dc.name}"
  datastore          = "${data.vsphere_datastore.ds.name}"
  type               = "thin"
  create_directories = "true"
}
