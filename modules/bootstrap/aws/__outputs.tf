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

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_name" {
  value = var.vpc_name
}

output "dmz_subnetworks" {
  value = aws_subnet.dmz.*.id
}

output "admin_subnetworks" {
  value =  aws_subnet.admin.*.id
}

output "vpc_dns_public_zone_id" {
  value = var.attach_dns_zone ? aws_route53_zone.vpc-public[0].zone_id : ""
}

output "vpc_dns_public_zone_name" {
  value = var.attach_dns_zone ? aws_route53_zone.vpc-public[0].name : ""
}

output "vpc_dns_private_zone_id" {
  value = var.attach_dns_zone ? aws_route53_zone.vpc-private[0].zone_id : ""
}

output "vpc_dns_private_zone_name" {
  value = var.attach_dns_zone ? aws_route53_zone.vpc-private[0].name : ""
}

#
# Bastion resource attributes
#

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_public_ip" {
  value = aws_eip.bastion-public.public_ip
}

output "bastion_fqdn" {
  value = var.attach_dns_zone ? aws_route53_record.vpc-external[0].name : ""
}

output "bastion_admin_fqdn" {
  value = (
    length(var.bastion_host_name) > 0 && !var.bastion_allow_public_ssh 
      ? join(".", list(var.bastion_host_name, var.vpc_dns_zone)) 
      : "N/A"
  )
}

output "bastion_admin_ssh_port" {
  value = var.bastion_admin_ssh_port
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