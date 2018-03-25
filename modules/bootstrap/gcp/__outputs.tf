#
# Module Outputs
#

#
# Network resource attributes
#
output "dmz_network" {
  value = "${module.network.dmz_network}"
}

output "dmz_subnetwork" {
  value = "${module.network.dmz_subnetwork}"
}

output "engineering_network" {
  value = "${module.network.engineering_network}"
}

output "engineering_subnetwork" {
  value = "${module.network.engineering_subnetwork}"
}

output "vpc_dns_zone_name" {
  value = "${google_dns_managed_zone.vpc.name}"
}

#
# Bastion resource attributes
#
output "bastion_fqdn" {
  value = "${google_dns_record_set.bastion-public.name}"
}

output "bastion_admin_fqdn" {
  value = "${google_dns_record_set.bastion-private.name}"
}

output "vpn_admin_password" {
  value = "${module.network.vpn_admin_password}"
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
