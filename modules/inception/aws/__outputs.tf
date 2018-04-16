#
# Module Outputs
#

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

output "bastion_admin_password" {
  value = "${module.config.bastion_admin_password}"
}
