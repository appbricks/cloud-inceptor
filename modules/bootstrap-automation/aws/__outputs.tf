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
output "dmz_subnetworks" {
  value = "${aws_subnet.dmz.*.id}"
}

output "admin_subnetworks" {
  value =  "${aws_subnet.admin.*.id}"
}

output "vpc_dns_public_zone_id" {
  value = "${aws_route53_zone.vpc-public.zone_id}"
}

output "vpc_dns_public_zone_name" {
  value = "${aws_route53_zone.vpc-public.name}"
}

output "vpc_dns_private_zone_id" {
  value = "${aws_route53_zone.vpc-private.zone_id}"
}

output "vpc_dns_private_zone_name" {
  value = "${aws_route53_zone.vpc-private.name}"
}

#
# Bastion resource attributes
#
output "bastion_instance_id" {
  value = "${aws_instance.bastion.id}"
}

output "bastion_fqdn" {
  value = "${aws_route53_record.vpc-public-external.name}"
}

output "bastion_admin_fqdn" {
  value = "${length(var.bastion_host_name) > 0 && !var.bastion_allow_public_ssh
    ? join(".", list(var.bastion_host_name, var.vpc_dns_zone)) : "N/A"}"
}

output "bastion_admin_password" {
  value = "${module.config.bastion_admin_password}"
}

# The api-key required to adminster the 
# internal zone managed by powerdns
output "powerdns_api_key" {
  value = "${module.config.powerdns_api_key}"
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

# ==== DEBUG OUTPUT ====

# output "debug_output" {
#   value = "${module.config.debug_output}"
# }