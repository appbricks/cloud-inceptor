#
# Network configuration
#

locals {
  num_networks = "${length(var.local_networks)}"
}

data "vsphere_network" "network" {
  count = "${local.num_networks}"

  name          = "${lookup(var.local_networks[count.index], "vsphere_network")}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
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
      list(
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
      )
    )
  }"
}
RESULT
    ,
  ]
}
