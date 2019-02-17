#
# Test instances on additional networks
#

locals {}

resource "vsphere_virtual_machine" "test" {
  count = "${max(0, local.num_networks - 2)}"

  name   = "test-${count.index}"
  folder = "inceptor-bootstrap"

  resource_pool_id = "${data.vsphere_resource_pool.rp.id}"
  datastore_id     = "${data.vsphere_datastore.eds.id}"

  memory   = "1024"
  num_cpus = "1"

  guest_id  = "${data.vsphere_virtual_machine.test-template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.test-template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.*.id[count.index + 2]}"
    adapter_type = "${data.vsphere_virtual_machine.test-template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.test-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.test-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.test-template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.test-template.id}"
  }

  extra_config {
    guestinfo.userdata          = "${data.template_cloudinit_config.test-cloudinit.*.rendered[count.index]}"
    guestinfo.userdata.encoding = "gzip+base64"
  }
}

#
# Test instance template
#

data "vsphere_virtual_machine" "test-template" {
  name          = "/${var.datacenter}/vm/templates/appbricks-ubuntu"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#
# Test instance Cloud-Init configuration
#

data "template_cloudinit_config" "test-cloudinit" {
  count = "${max(0, local.num_networks - 2)}"

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
   - ${module.bootstrap.default_openssh_public_key}
   groups: [ubuntu, adm, cdrom, sudo, dip, plugdev, lpadmin, sambashare]

network:
  config: disabled
  
USER_DATA
  }
}

output "test_instance_ips" {
  value = "${vsphere_virtual_machine.test.*.default_ip_address}"
}
