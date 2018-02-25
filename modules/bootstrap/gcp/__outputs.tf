#
# Module Outputs
#

output "bastion_fqdn" {
  value = "${google_dns_record_set.bastion-public.name}"
}

output "bastion_admin_fqdn" {
  value = "${google_dns_record_set.bastion-private.name}"
}

output "vpn_admin_password" {
  value = "${module.vpc.vpn_admin_password}"
}

output "concourse_admin_password" {
  value = "${var.concourse_admin_password}"
}
