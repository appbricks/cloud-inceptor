#
# Module Outputs
#

#
# Root CA for signing self-signed cert
#
output "root_ca_key" {
  value = module.config.root_ca_key
}

output "root_ca_cert" {
  value = module.config.root_ca_cert
}

#
# Network resource attributes
#
output "dmz_network" {
  value = google_compute_network.dmz.self_link
}

output "dmz_subnetwork" {
  value = google_compute_subnetwork.dmz.self_link
}

output "admin_network" {
  value = google_compute_network.admin.self_link
}

output "admin_subnetwork" {
  value = google_compute_subnetwork.admin.self_link
}

output "vpc_dns_zone_name" {
  value = google_dns_managed_zone.vpc.name
}

#
# Bastion resource attributes
#
output "bastion_instance_id" {
  value = google_compute_instance.bastion.id
}

output "bastion_fqdn" {
  value = google_dns_record_set.vpc-public.name
}

output "bastion_admin_fqdn" {
  value = "${length(var.bastion_host_name) > 0 && !var.bastion_allow_public_ssh
    ? google_dns_record_set.vpc-admin.name : "N/A"}"
}

output "bastion_admin_user" {
  value = var.bastion_admin_user
}

output "bastion_admin_password" {
  value = module.config.bastion_admin_password
}

output "bastion_admin_sshkey" {
  value = module.config.bastion_admin_sshkey
}

output "bastion_openssh_public_key" {
  value = module.config.bastion_openssh_public_key
}

# The api-key required to adminster the 
# internal zone managed by powerdns
output "powerdns_api_key" {
  value = module.config.powerdns_api_key
}

#
# Default SSH key to use within VPC
#

output "default_openssh_private_key" {
  value = tls_private_key.default-ssh-key.private_key_pem
}

output "default_openssh_public_key" {
  value = tls_private_key.default-ssh-key.public_key_openssh
}

# ==== DEBUG OUTPUT ====

# output "debug_output" {
#   value = module.config.debug_output
# }