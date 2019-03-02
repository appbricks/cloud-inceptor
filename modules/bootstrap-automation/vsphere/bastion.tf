#
# Inception Bastion
#

locals {
  bastion_dmz_itf_ip = "${lookup(var.local_networks[0], "bastion_ip")}"

  bastion_admin_itf_ip = "${local.num_networks > 0 
    ? lookup(var.local_networks[1], "bastion_ip",
        cidrhost(lookup(var.local_networks[1], "cidr"), var.bastion_nic_hostnum)
      )
    : ""}"

  bastion_public_ip = "${
    length(var.bastion_public_ip) > 0 
      ? var.bastion_public_ip 
      : local.bastion_dmz_itf_ip}"
}

#
# Bastion instance
#
# A resource needs for each nic enumeration as network_interface list 
# cannot be assigned dynamically. This needs to be refactored when 
# migrating to Terraform 0.12 which will support dynamic resources.
#

resource "vsphere_virtual_machine" "bastion-1nic" {
  count = "${local.num_networks == 1 ? 1 : 0 }"

  name   = "inceptor"
  folder = "${vsphere_folder.vpc.path}"

  resource_pool_id = "${data.vsphere_resource_pool.rp.id}"
  datastore_id     = "${data.vsphere_datastore.eds.id}"

  memory   = "${var.bastion_instance_memory}"
  num_cpus = "${var.bastion_instance_cpus}"

  guest_id              = "${data.vsphere_virtual_machine.bastion-template.guest_id}"
  scsi_type             = "${data.vsphere_virtual_machine.bastion-template.scsi_type}"
  scsi_controller_count = 2

  network_interface = [
    {
      network_id   = "${data.vsphere_network.network.*.id[0]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
  ]

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.bastion-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bastion-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bastion-template.disks.0.thin_provisioned}"
  }

  disk {
    label        = "disk1"
    attach       = "true"
    disk_mode    = "independent_persistent"
    disk_sharing = "sharingNone"

    datastore_id = "${data.vsphere_datastore.pds.id}"
    path         = "${vsphere_virtual_disk.bastion-data-disk.vmdk_path}"

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
  count = "${local.num_networks == 2 ? 1 : 0 }"

  name   = "inceptor"
  folder = "${vsphere_folder.vpc.path}"

  resource_pool_id = "${data.vsphere_resource_pool.rp.id}"
  datastore_id     = "${data.vsphere_datastore.eds.id}"

  memory   = "${var.bastion_instance_memory}"
  num_cpus = "${var.bastion_instance_cpus}"

  guest_id              = "${data.vsphere_virtual_machine.bastion-template.guest_id}"
  scsi_type             = "${data.vsphere_virtual_machine.bastion-template.scsi_type}"
  scsi_controller_count = 2

  network_interface = [
    {
      network_id   = "${data.vsphere_network.network.*.id[0]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[1]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
  ]

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.bastion-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bastion-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bastion-template.disks.0.thin_provisioned}"
  }

  disk {
    label        = "disk1"
    attach       = "true"
    disk_mode    = "independent_persistent"
    disk_sharing = "sharingNone"

    datastore_id = "${data.vsphere_datastore.pds.id}"
    path         = "${vsphere_virtual_disk.bastion-data-disk.vmdk_path}"

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

resource "vsphere_virtual_machine" "bastion-3nic" {
  count = "${local.num_networks == 3 ? 1 : 0 }"

  name   = "inceptor"
  folder = "${vsphere_folder.vpc.path}"

  resource_pool_id = "${data.vsphere_resource_pool.rp.id}"
  datastore_id     = "${data.vsphere_datastore.eds.id}"

  memory   = "${var.bastion_instance_memory}"
  num_cpus = "${var.bastion_instance_cpus}"

  guest_id              = "${data.vsphere_virtual_machine.bastion-template.guest_id}"
  scsi_type             = "${data.vsphere_virtual_machine.bastion-template.scsi_type}"
  scsi_controller_count = 2

  network_interface = [
    {
      network_id   = "${data.vsphere_network.network.*.id[0]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[1]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[2]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
  ]

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.bastion-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bastion-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bastion-template.disks.0.thin_provisioned}"
  }

  disk {
    label        = "disk1"
    attach       = "true"
    disk_mode    = "independent_persistent"
    disk_sharing = "sharingNone"

    datastore_id = "${data.vsphere_datastore.pds.id}"
    path         = "${vsphere_virtual_disk.bastion-data-disk.vmdk_path}"

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

resource "vsphere_virtual_machine" "bastion-4nic" {
  count = "${local.num_networks == 4 ? 1 : 0 }"

  name   = "inceptor"
  folder = "${vsphere_folder.vpc.path}"

  resource_pool_id = "${data.vsphere_resource_pool.rp.id}"
  datastore_id     = "${data.vsphere_datastore.eds.id}"

  memory   = "${var.bastion_instance_memory}"
  num_cpus = "${var.bastion_instance_cpus}"

  guest_id              = "${data.vsphere_virtual_machine.bastion-template.guest_id}"
  scsi_type             = "${data.vsphere_virtual_machine.bastion-template.scsi_type}"
  scsi_controller_count = 2

  network_interface = [
    {
      network_id   = "${data.vsphere_network.network.*.id[0]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[1]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[2]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[3]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
  ]

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.bastion-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bastion-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bastion-template.disks.0.thin_provisioned}"
  }

  disk {
    label        = "disk1"
    attach       = "true"
    disk_mode    = "independent_persistent"
    disk_sharing = "sharingNone"

    datastore_id = "${data.vsphere_datastore.pds.id}"
    path         = "${vsphere_virtual_disk.bastion-data-disk.vmdk_path}"

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

resource "vsphere_virtual_machine" "bastion-5nic" {
  count = "${local.num_networks == 5 ? 1 : 0 }"

  name   = "inceptor"
  folder = "${vsphere_folder.vpc.path}"

  resource_pool_id = "${data.vsphere_resource_pool.rp.id}"
  datastore_id     = "${data.vsphere_datastore.eds.id}"

  memory   = "${var.bastion_instance_memory}"
  num_cpus = "${var.bastion_instance_cpus}"

  guest_id              = "${data.vsphere_virtual_machine.bastion-template.guest_id}"
  scsi_type             = "${data.vsphere_virtual_machine.bastion-template.scsi_type}"
  scsi_controller_count = 2

  network_interface = [
    {
      network_id   = "${data.vsphere_network.network.*.id[0]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[1]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[2]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[3]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
    {
      network_id   = "${data.vsphere_network.network.*.id[4]}"
      adapter_type = "${data.vsphere_virtual_machine.bastion-template.network_interface_types[0]}"
    },
  ]

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.bastion-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bastion-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bastion-template.disks.0.thin_provisioned}"
  }

  disk {
    label        = "disk1"
    attach       = "true"
    disk_mode    = "independent_persistent"
    disk_sharing = "sharingNone"

    datastore_id = "${data.vsphere_datastore.pds.id}"
    path         = "${vsphere_virtual_disk.bastion-data-disk.vmdk_path}"

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
# Bastion template
#

data "vsphere_virtual_machine" "bastion-template" {
  name          = "/${var.datacenter}/vm/${var.bastion_template_path}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#
# Bastion data volume
#

resource "vsphere_virtual_disk" "bastion-data-disk" {
  size               = "${var.bastion_data_disk_size}"
  vmdk_path          = "/${var.vpc_name}-bootstrap/data.vmdk"
  datacenter         = "${data.vsphere_datacenter.dc.name}"
  datastore          = "${data.vsphere_datastore.pds.name}"
  type               = "thin"
  create_directories = "true"
}
