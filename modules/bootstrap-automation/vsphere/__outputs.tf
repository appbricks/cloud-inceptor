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
  value = "${local.bastion_dmz_itf_ip}"
}

output "bastion_admin_fqdn" {
  value = "${local.num_networks == 1 
    ? local.bastion_dmz_itf_ip
    : local.bastion_admin_itf_ip}"
}

output "bastion_admin_password" {
  value = "${module.config.bastion_admin_password}"
}

#
# Jumpbox resource attributes
#

output "jumpbox_ip" {
  value = "${local.jumpbox_ip}"
}

# The api-key required to adminster the 
# internal zone managed by powerdns
output "powerdns_api_key" {
  value = "${module.config.powerdns_api_key}"
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
