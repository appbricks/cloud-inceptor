#
# Hosted zone for VPC
#

locals {

  dns_name_components = split(".", var.vpc_dns_zone)
  parent_dns_name     = join(".", slice(local.dns_name_components, 1, length(local.dns_name_components)))
  vpc_dns_hostname        = element((local.dns_name_components), 0)
}

data "azurerm_dns_zone" "parent" {
  count = var.attach_dns_zone ? 1 : 0

  name                = local.parent_dns_name
  resource_group_name = var.source_resource_group
}

#
# Add Public DNS zone's nameservers to the parent zone
#
resource "azurerm_dns_ns_record" "vpc" {
  count = var.attach_dns_zone ? 1 : 0

  name         = local.vpc_dns_hostname
  zone_name    = data.azurerm_dns_zone.parent[0].name

  resource_group_name = var.source_resource_group

  ttl  = 300

  records = [
    element(tolist(azurerm_dns_zone.vpc-public.name_servers), 0),
    element(tolist(azurerm_dns_zone.vpc-public.name_servers), 1),
    element(tolist(azurerm_dns_zone.vpc-public.name_servers), 2),
    element(tolist(azurerm_dns_zone.vpc-public.name_servers), 3)
  ]
}

#
# Public Zone
#
resource "azurerm_dns_zone" "vpc-public" {
  name                = var.vpc_dns_zone
  resource_group_name = azurerm_resource_group.bootstrap.name
}

#
# VPC Bastion instance DNS
#

resource "azurerm_dns_a_record" "vpc-public" {
  count = var.attach_dns_zone ? 1 : 0

  name      = local.vpc_dns_hostname
  zone_name = data.azurerm_dns_zone.parent[0].name

  resource_group_name = var.source_resource_group

  ttl     = "300"
  records = [azurerm_public_ip.bastion-public.ip_address]
}

resource "azurerm_dns_a_record" "vpc-admin" {
  count = length(var.bastion_host_name) > 0 && !var.bastion_allow_public_ssh ? 1 : 0

  name = var.bastion_host_name
  zone_name = azurerm_dns_zone.vpc-public.name

  resource_group_name = azurerm_resource_group.bootstrap.name

  ttl     = "300"
  records = [azurerm_network_interface.bastion-admin.ip_configuration[0].private_ip_address]
}

resource "azurerm_dns_a_record" "vpc-mail" {
  count = length(var.smtp_relay_host) == 0 ? 0 : 1 

  name      = "mail.${var.vpc_dns_zone}"
  zone_name = azurerm_dns_zone.vpc-public.name

  resource_group_name = azurerm_resource_group.bootstrap.name

  ttl     = "300"
  records = [azurerm_network_interface.bastion-admin.ip_configuration[0].private_ip_address]
}

resource "azurerm_dns_mx_record" "vpc-mx" {
  count = length(var.smtp_relay_host) == 0 ? 0 : 1 

  name      = var.vpc_dns_zone
  zone_name = azurerm_dns_zone.vpc-public.name

  resource_group_name = azurerm_resource_group.bootstrap.name

  ttl = "300"

  record {
    preference = 1
    exchange   = var.vpc_dns_zone
  }
}

resource "azurerm_dns_txt_record" "vpc-txt" {
  count = length(var.smtp_relay_host) == 0 ? 0 : 1 

  name      = var.vpc_dns_zone
  zone_name = azurerm_dns_zone.vpc-public.name

  resource_group_name = azurerm_resource_group.bootstrap.name

  ttl = "300"

  record {
    value = "v=spf1 mx -all"
  }
}
