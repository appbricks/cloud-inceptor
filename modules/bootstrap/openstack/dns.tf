#
# External DNS for OpenStack/OVH deployments (Route53, Cloud DNS, or Azure DNS)
#

module "dns" {
  count  = var.attach_dns_zone && var.dns_provider != "" ? 1 : 0
  source = "../../../modules/dns"

  attach_dns_zone = var.attach_dns_zone
  dns_provider    = var.dns_provider

  vpc_name     = var.vpc_name
  vpc_dns_zone = var.vpc_dns_zone

  bastion_public_ip    = openstack_networking_floatingip_v2.bastion_public.address
  bastion_admin_itf_ip = local.bastion_admin_itf_ip

  bastion_host_name        = var.bastion_host_name
  bastion_allow_public_ssh = var.bastion_allow_public_ssh
  smtp_relay_host          = var.smtp_relay_host

  parent_dns_zone_name = var.dns_parent_zone_name

  azure_resource_group = var.dns_azure_resource_group
}
