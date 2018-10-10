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
