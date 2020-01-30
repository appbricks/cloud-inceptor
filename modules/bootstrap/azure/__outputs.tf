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
# VPC and network resource attributes
#

output "vpc_resource_group" {
  value = azurerm_resource_group.bootstrap.name
}

output "vpc_name" {
  value = var.vpc_name
}

output "vpc_network" {
  value = azurerm_virtual_network.vpc.id
}

output "vpc_route_table" {
  value = azurerm_route_table.vpc.id
}

output "dmz_subnetwork" {
  value = azurerm_subnet.dmz.id
}

output "admin_subnetwork" {
  value = azurerm_subnet.admin.id
}

output "vpc_dns_zone_name" {
  value = azurerm_dns_zone.vpc-public.name
}

#
# Bastion resource attributes
#

output "bastion_instance_id" {
  value = azurerm_virtual_machine.bastion.id
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion-public.ip_address
}

output "bastion_fqdn" {
  value = var.vpc_dns_zone
}

output "bastion_admin_fqdn" {
  value = length(var.bastion_host_name) > 0 && !var.bastion_allow_public_ssh ? join(".", list(var.bastion_host_name, var.vpc_dns_zone)) : "N/A"
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