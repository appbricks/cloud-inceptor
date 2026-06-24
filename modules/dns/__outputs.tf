output "vpc_dns_public_zone_id" {
  value = (
    local.use_aws
    ? aws_route53_zone.public[0].zone_id
    : (
      local.use_google
      ? google_dns_managed_zone.vpc[0].id
      : (
        local.use_azure
        ? azurerm_dns_zone.vpc_public[0].id
        : ""
      )
    )
  )
}

output "vpc_dns_public_zone_name" {
  value = local.enabled ? var.vpc_dns_zone : ""
}

output "vpc_dns_private_zone_id" {
  value = ""
}

output "vpc_dns_private_zone_name" {
  value = ""
}

output "bastion_fqdn" {
  value = (
    local.enabled
    ? var.vpc_dns_zone
    : var.bastion_public_ip
  )
}
