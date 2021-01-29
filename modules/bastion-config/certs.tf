#
# Root CA
#

locals {
  root_ca_key  = length(var.root_ca_key) > 0 && length(var.root_ca_cert) > 0 ? var.root_ca_key : tls_private_key.root-ca-key.private_key_pem
  root_ca_cert = length(var.root_ca_key) > 0 && length(var.root_ca_cert) > 0 ? var.root_ca_cert : tls_self_signed_cert.root-ca.cert_pem
}

resource "tls_private_key" "root-ca-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "root-ca" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.root-ca-key.private_key_pem

  subject {
    common_name         = "Root CA for ${var.vpc_name}"
    organization        = var.company_name
    organizational_unit = var.organization_name
    locality            = var.locality
    province            = var.province
    country             = var.country
  }

  allowed_uses = [
    "cert_signing",
  ]

  validity_period_hours = 87600
  is_ca_certificate     = true
}

#
# Self-signed certificate for Bastion server
#
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "bastion" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.bastion.private_key_pem

  dns_names = [
    var.bastion_fqdn
  ]

  ip_addresses = [
    var.bastion_public_ip,
    var.bastion_dmz_itf_ip,
    var.bastion_admin_itf_ip,
  ]

  subject {
    common_name         = var.bastion_fqdn
    organization        = var.company_name
    organizational_unit = var.organization_name
    locality            = var.locality
    province            = var.province
    country             = var.country
  }
}

resource "tls_locally_signed_cert" "bastion" {
  cert_request_pem = tls_cert_request.bastion.cert_request_pem

  ca_key_algorithm = "RSA"

  ca_private_key_pem = local.root_ca_key
  ca_cert_pem        = local.root_ca_cert

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "data_encipherment",
    "server_auth",
  ]
}
