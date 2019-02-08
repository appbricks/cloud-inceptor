#
# Jumpbox
#

locals {
  local_dns = "${length(var.vpc_internal_dns_zones) > 0 
    ? element(var.vpc_internal_dns_zones, 0) : ""}"

  jumpbox_dns = "${var.deploy_jumpbox == "true" && length(local.local_dns) > 0 
    ? format("jumpbox.%s", local.local_dns) : ""}"

  jumpbox_dns_record = "${length(local.jumpbox_dns) > 0 && length(var.jumpbox_admin_ip) > 0
    ? format("%s:%s", local.jumpbox_dns, var.jumpbox_admin_ip) : ""}"
}

resource "vsphere_virtual_machine" "jumpbox" {
  count = "${length(local.jumpbox_dns) > 0 ? 1 : 0}"

  name   = "jumpbox"
  folder = "/${var.datacenter}/vm/${vsphere_folder.vpc.path}"

  resource_pool_id = "${data.vsphere_resource_pool.rp.id}"
  datastore_id     = "${data.vsphere_datastore.eds.id}"

  memory   = "${var.jumpbox_instance_memory}"
  num_cpus = "${var.jumpbox_instance_cpus}"

  guest_id  = "${data.vsphere_virtual_machine.jumpbox-template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.jumpbox-template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.admin.id}"
    adapter_type = "${data.vsphere_virtual_machine.jumpbox-template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.jumpbox-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.jumpbox-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.jumpbox-template.disks.0.thin_provisioned}"
  }

  disk {
    label = "disk1"
    size  = "${vsphere_virtual_disk.jumpbox-data-disk.size}"
    path  = "${vsphere_virtual_disk.jumpbox-data-disk.vmdk_path}"

    unit_number = 14
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.jumpbox-template.id}"
  }

  extra_config {
    guestinfo.userdata          = "${data.template_cloudinit_config.jumpbox-cloudinit.rendered}"
    guestinfo.userdata.encoding = "gzip+base64"
  }

  wait_for_guest_net_timeout  = -1
  wait_for_guest_net_routable = false
}

#
# Jumpbox Cloud-Init configuration
#

data "template_cloudinit_config" "jumpbox-cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    content = <<USER_DATA
#cloud-config
users:
  - default

system_info:
  default_user:
   name: ubuntu
   gecos: Ubuntu
   lock_passwd: False
   home: /home/ubuntu
   shell: /bin/bash
   ssh_authorized_keys:
   - ${tls_private_key.default-ssh-key.public_key_openssh}
   groups: [ubuntu, adm, cdrom, sudo, dip, plugdev, lpadmin, sambashare]

network:
  config: disabled
  
runcmd:
- |
  set -x
  rm -f /etc/network/interfaces.d/*

  # Setup LAN network interface
  itf=$(ip a | awk '/^[0-9]+: (eth|ens?)[0-9]+:/{ print substr($2,1,length($2)-1) }')
  ifdown $itf
  ip addr flush dev $itf

  cat << ---EOF > /etc/network/interfaces.d/99-$itf.cfg
  auto $itf
  iface $itf inet static
    address ${var.jumpbox_admin_ip}
    netmask ${cidrnetmask(var.admin_network_cidr)}
    gateway ${var.admin_network_gateway}
  ---EOF
  ifup $itf

  echo "nameserver ${var.bastion_admin_ip}" > /etc/resolvconf/resolv.conf.d/head
  echo "search ${element(var.vpc_internal_dns_zones, 0)}" >> /etc/resolvconf/resolv.conf.d/head
  resolvconf -u

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

resource "vsphere_virtual_disk" "jumpbox-data-disk" {
  count = "${length(local.jumpbox_dns) > 0 ? 1 : 0}"

  size               = "${var.jumpbox_data_disk_size}"
  vmdk_path          = "/jumpbox/data.vmdk"
  datacenter         = "${data.vsphere_datacenter.dc.name}"
  datastore          = "${data.vsphere_datastore.pds.name}"
  type               = "thin"
  create_directories = "true"
}
