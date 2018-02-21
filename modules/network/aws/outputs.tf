#
# Module Outputs
#

#
# VPC resource attributes
#
output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.main.cidr_block}"
}

output "vpc_available_subnet" {
  # This module creates 2 subnets for each  AZs
  value = "${var.subnet_start + (length(data.aws_availability_zones.available.names)*2)}"
}

#
# Network resource attributes
#
output "dmz_subnets" {
  value = "${aws_subnet.dmz.*.id}"
}

output "engineering_subnets" {
  value = "${aws_subnet.engineering.*.id}"
}

#
# Bastion resource attributes
#
output "bastion_fqdn" {
  value = "${length(var.bastion_host_name) == 0 ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}"
}

output "bastion_private_ip" {
  value = "${aws_network_interface.bastion-private.private_ips[0]}"
}

output "bastion_public_ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "vpn_admin_password" {
  value = "${module.common.vpn_admin_password}"
}
