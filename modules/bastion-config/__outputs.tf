#
# Module Outputs
#

#
# Root CA for signing self-signed cert
#
output "root_ca_key" {
  value = "${local.root_ca_key}"
}

output "root_ca_cert" {
  value = "${local.root_ca_cert}"
}

# Cloud-Init configuration file setting 
# up the Bastion instance on first boot
output "bastion_cloud_init_config" {
  value = "${data.template_cloudinit_config.bastion-cloudinit.rendered}"
}

# The password generated for the VPN admin user
output "bastion_admin_password" {
  value = "${random_string.bastion-admin-password.result}"
}
