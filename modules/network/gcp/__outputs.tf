#
# Module Outputs
#

#
# Root CA for signing self-signed cert
#
output "root_ca_key" {
  value = "${module.inception.root_ca_key}"
}

output "root_ca_cert" {
  value = "${module.inception.root_ca_cert}"
}

#
# Network resource attributes
#
output "dmz_network" {
  value = "${google_compute_network.dmz.self_link}"
}

output "dmz_subnetwork" {
  value = "${google_compute_subnetwork.dmz.self_link}"
}

output "admin_network" {
  value = "${google_compute_network.admin.self_link}"
}

output "admin_subnetwork" {
  value = "${google_compute_subnetwork.admin.self_link}"
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

output "bastion_admin_password" {
  value = "${module.inception.bastion_admin_password}"
}
