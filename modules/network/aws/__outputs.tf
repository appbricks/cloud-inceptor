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
  value = "${module.inception.bastion_fqdn}"
}

output "bastion_private_ip" {
  value = "${module.inception.bastion_private_ip}"
}

output "bastion_public_ip" {
  value = "${module.inception.bastion_public_ip}"
}

output "vpn_admin_password" {
  value = "${module.inception.vpn_admin_password}"
}
