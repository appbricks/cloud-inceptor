#
# Shared DNS module inputs
#

variable "attach_dns_zone" {
  type    = bool
  default = false
}

variable "dns_provider" {
  type        = string
  default     = ""
  description = "External DNS provider: aws, google, azure, or empty to skip."
}

variable "vpc_name" {
  type = string
}

variable "vpc_dns_zone" {
  type = string
}

variable "bastion_public_ip" {
  type = string
}

variable "bastion_admin_itf_ip" {
  type = string
}

variable "bastion_host_name" {
  default = ""
}

variable "bastion_allow_public_ssh" {
  default = true
}

variable "smtp_relay_host" {
  default = ""
}

#
# Parent zone for NS delegation (all providers)
#
variable "parent_dns_zone_name" {
  default     = ""
  description = "Parent DNS zone for NS delegation (e.g. ovh.appbricks.io). Defaults to the parent domain of vpc_dns_zone."
}

#
# Azure DNS zone's resource group
#
variable "azure_resource_group" {
  default     = ""
  description = "Azure resource group for parent and delegated DNS zones (required when dns_provider is azure)."
}
