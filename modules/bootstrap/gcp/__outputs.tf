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

output "concourse_admin_password" {
  value = "${var.concourse_admin_password}"
}
