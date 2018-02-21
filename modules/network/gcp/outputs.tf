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
# Bastion resource attributesd
#
output "bastion_fqdn" {
  value = "${length(var.bastion_host_name) == 0 ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}"
}

output "bastion-private-ip" {
  value = "${google_compute_address.bastion-engineering.address}"
}

output "bastion-public-ip" {
  value = "${google_compute_address.bastion-public.address}"
}

output "vpn_admin_password" {
  value = "${module.common.vpn_admin_password}"
}
