#
# Azure DNS
#

data "azurerm_dns_zone" "parent" {
  count = local.use_azure ? 1 : 0

  name                = local.azure_parent_zone_name
  resource_group_name = var.azure_resource_group
}

resource "azurerm_dns_zone" "vpc_public" {
  count = local.use_azure ? 1 : 0

  name                = var.vpc_dns_zone
  resource_group_name = var.azure_resource_group
}

resource "azurerm_dns_ns_record" "vpc" {
  count = local.use_azure ? 1 : 0

  name                = local.vpc_dns_hostname
  zone_name           = data.azurerm_dns_zone.parent[0].name
  resource_group_name = var.azure_resource_group

  ttl = 300

  records = [
    element(tolist(azurerm_dns_zone.vpc_public[0].name_servers), 0),
    element(tolist(azurerm_dns_zone.vpc_public[0].name_servers), 1),
    element(tolist(azurerm_dns_zone.vpc_public[0].name_servers), 2),
    element(tolist(azurerm_dns_zone.vpc_public[0].name_servers), 3),
  ]
}

resource "azurerm_dns_a_record" "vpc_public" {
  count = local.use_azure ? 1 : 0

  name                = local.vpc_dns_hostname
  zone_name           = data.azurerm_dns_zone.parent[0].name
  resource_group_name = var.azure_resource_group

  ttl     = "300"
  records = [var.bastion_public_ip]
}

resource "azurerm_dns_a_record" "vpc_admin" {
  count = (
    local.use_azure
    && length(var.bastion_host_name) > 0
    && !var.bastion_allow_public_ssh
  ) ? 1 : 0

  name                = var.bastion_host_name
  zone_name           = azurerm_dns_zone.vpc_public[0].name
  resource_group_name = var.azure_resource_group

  ttl     = "300"
  records = [var.bastion_admin_itf_ip]
}

resource "azurerm_dns_a_record" "vpc_mail" {
  count = local.use_azure && length(var.smtp_relay_host) > 0 ? 1 : 0

  name                = "mail.${var.vpc_dns_zone}"
  zone_name           = azurerm_dns_zone.vpc_public[0].name
  resource_group_name = var.azure_resource_group

  ttl     = "300"
  records = [var.bastion_admin_itf_ip]
}

resource "azurerm_dns_mx_record" "vpc_mx" {
  count = local.use_azure && length(var.smtp_relay_host) > 0 ? 1 : 0

  name                = var.vpc_dns_zone
  zone_name           = azurerm_dns_zone.vpc_public[0].name
  resource_group_name = var.azure_resource_group

  ttl = "300"

  record {
    preference = 1
    exchange   = var.vpc_dns_zone
  }
}

resource "azurerm_dns_txt_record" "vpc_txt" {
  count = local.use_azure && length(var.smtp_relay_host) > 0 ? 1 : 0

  name                = var.vpc_dns_zone
  zone_name           = azurerm_dns_zone.vpc_public[0].name
  resource_group_name = var.azure_resource_group

  ttl = "300"

  record {
    value = "v=spf1 mx -all"
  }
}
