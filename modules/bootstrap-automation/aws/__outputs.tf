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

output "vpc_dns_zone_name" {
  value = "${google_dns_managed_zone.vpc.name}"
}

#
# Bastion resource attributes
#
output "bastion_fqdn" {
  value = "${google_dns_record_set.vpc-public.name}"
}

output "bastion_admin_fqdn" {
  value = "${google_dns_record_set.vpc-admin.name}"
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
