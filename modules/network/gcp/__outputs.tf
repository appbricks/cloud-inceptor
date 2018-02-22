#
# Module Outputs
#

#
# Network resource attributes
#
output "dmz_network_name" {
  value = "${google_compute_network.dmz.name}"
}

output "dmz_subnetwork_name" {
  value = "${google_compute_subnetwork.dmz.name}"
}

output "engineering_network_name" {
  value = "${google_compute_network.engineering.name}"
}

output "engineering_subnetwork_name" {
  value = "${google_compute_subnetwork.engineering.name}"
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
