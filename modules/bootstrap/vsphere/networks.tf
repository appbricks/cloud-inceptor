#
# Network configuration
#

locals {
  num_networks = "${length(var.local_networks)}"

  local_networks = "${matchkeys(
    data.null_data_source.local_networks.*.outputs, 
    data.null_data_source.local_networks.*.outputs.create, 
    tolist(["true"]))}"
}

data "null_data_source" "local_networks" {
  count = "${length(var.local_networks)}"

  inputs = {
    vsphere_network = "${lookup(var.local_networks[count.index], "vsphere_network", "")}"
    create          = "${lookup(var.local_networks[count.index], "create", "")}"
    vlan_id         = "${lookup(var.local_networks[count.index], "vlan_id", "4094")}"
  }
}

resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = "inceptor-local-network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"

  uplinks         = ["uplink1"]
  active_uplinks  = ["uplink1"]
  standby_uplinks = []

  host = [
    {
      host_system_id = "${data.vsphere_host.host.0.id}"
      devices        = ["${var.esxi_host_vmnics}"]
    },
  ]
}

resource "vsphere_distributed_port_group" "dpg" {
  count = "${length(local.local_networks)}"

  name                            = "${lookup(local.local_networks[count.index], "vsphere_network")}"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_id = "${lookup(local.local_networks[count.index], "vlan_id")}"
}

data "vsphere_network" "network" {
  count = "${local.num_networks}"

  name          = "${lookup(var.local_networks[count.index], "vsphere_network")}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"

  # Additional networks may be created by
  # the bootstrap module so this data
  # resource needs to be executed only
  # after the module has completed.
  depends_on = [
    "vsphere_distributed_port_group.dpg",
  ]
}

data "null_data_source" "vsphere_networks" {
  count = "${local.num_networks}"

  inputs = {
    name = "${data.vsphere_network.network.*.name[count.index]}"
    id   = "${data.vsphere_network.network.*.id[count.index]}"
  }
}

data "external" "bastion-nic-config" {
  count = "${local.num_networks}"

  # Each bastion IP configuration should be a
  # '|' delimited string of:
  #
  # - IPv4 address of network interface
  # - CIDR of subnet to which this interface is attached
  # - CIDR of LAN to which a static route will be created via this interface
  # - Gateway to configure for the interface's subnet
  # - DHCPd lease start (if providing DHCP leases on LAN segment)
  # - DHCPd lease end (if providing DHCP leases on LAN segment)
  #
  # If the gateway is not provided then it is assumed the
  # bastion instance will provide routing as well as NATing
  # for the LAN the interface is attached to.

  program = [
    "echo",
    <<RESULT
{
  "config": "${
    join("|", 
      tolist([
        length(lookup(var.local_networks[count.index], "bastion_ip", "")) > 0
          ? lookup(var.local_networks[count.index], "bastion_ip", "")
          : cidrhost(lookup(var.local_networks[count.index], "cidr"), var.bastion_nic_hostnum)
        ,
        lookup(var.local_networks[count.index], "cidr", ""),
        length(lookup(var.local_networks[count.index], "static_route", "")) > 0
          ? lookup(var.local_networks[count.index], "static_route", "")
          : ""
        ,
        lookup(var.local_networks[count.index], "gateway", ""),
        cidrhost(lookup(var.local_networks[count.index], "cidr", ""), -2 - var.dhcpd_lease_range),
        cidrhost(lookup(var.local_networks[count.index], "cidr", ""), -2),
      ])
    )
  }"
}
RESULT
    ,
  ]
}
