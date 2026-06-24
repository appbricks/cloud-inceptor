locals {
  enabled = var.attach_dns_zone && var.dns_provider != ""

  use_aws    = local.enabled && var.dns_provider == "aws"
  use_google = local.enabled && var.dns_provider == "google"
  use_azure  = local.enabled && var.dns_provider == "azure"

  dns_name_components = split(".", var.vpc_dns_zone)
  parent_dns_name = join(".", slice(
    local.dns_name_components,
    1,
    length(local.dns_name_components)
  ))
  vpc_dns_hostname = element(local.dns_name_components, 0)

  parent_dns_zone_name = (
    length(var.parent_dns_zone_name) > 0
    ? trimsuffix(var.parent_dns_zone_name, ".")
    : local.parent_dns_name
  )

  aws_parent_zone_name   = "${local.parent_dns_zone_name}."
  google_parent_dns_name = "${local.parent_dns_zone_name}."
  azure_parent_zone_name = local.parent_dns_zone_name
}
