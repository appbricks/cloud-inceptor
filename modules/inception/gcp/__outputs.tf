#
# Module Outputs
#

#
# Root CA for signing self-signed cert
#
output "root_ca_key" {
  value = "${module.config.root_ca_key}"
}

output "root_ca_cert" {
  value = "${module.config.root_ca_cert}"
}

#
# Bastion resource attributesd
#
output "bastion_fqdn" {
  value = "${length(var.bastion_host_name) == 0 ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}"
}

output "bastion_private_ip" {
  value = "${google_compute_address.bastion-mgmt.address}"
}

output "bastion_public_ip" {
  value = "${google_compute_address.bastion-public.address}"
}

output "vpn_admin_password" {
  value = "${module.config.vpn_admin_password}"
}
