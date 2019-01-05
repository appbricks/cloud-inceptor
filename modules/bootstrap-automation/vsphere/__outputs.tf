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
# Bastion resource attributes
#

output "bastion_fqdn" {
  value = "${local.has_dmz_network ? var.bastion_dmz_ip : var.bastion_admin_ip}"
}

output "bastion_admin_fqdn" {
  value = "${var.bastion_allow_public_ssh && local.has_dmz_network 
    ? var.bastion_dmz_ip : var.bastion_admin_ip}"
}

output "bastion_admin_password" {
  value = "${module.config.bastion_admin_password}"
}

#
# Default SSH key to use within VPC
#

output "default_openssh_public_key" {
  value = "${tls_private_key.default-ssh-key.public_key_openssh}"
}

output "default_openssh_private_key" {
  value = "${tls_private_key.default-ssh-key.private_key_pem}"
}
