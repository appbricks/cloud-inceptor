#
# Module Outputs
#

#
# Network resource attributes
#
output "dmz_subnets" {
  value = "${aws_subnet.dmz.*.id}"
}

output "mgmt_subnets" {
  value = "${aws_subnet.mgmt.*.id}"
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
