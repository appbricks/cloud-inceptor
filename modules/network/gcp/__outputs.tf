#
# Module Outputs
#

#
# Network resource attributes
#
output "dmz_network" {
  value = "${google_compute_network.dmz.self_link}"
}

output "dmz_subnetwork" {
  value = "${google_compute_subnetwork.dmz.self_link}"
}

output "engineering_network" {
  value = "${google_compute_network.engineering.self_link}"
}

output "engineering_subnetwork" {
  value = "${google_compute_subnetwork.engineering.self_link}"
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
