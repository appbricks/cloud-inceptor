#
# Root CA
#

resource "tls_private_key" "root-ca-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "root-ca" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.root-ca-key.private_key_pem}"

  subject {
    common_name         = "Local Root CA"
    organization        = "${var.company_name}"
    organizational_unit = "${var.organization_name}"
    locality            = "${var.locality}"
    province            = "${var.province}"
    country             = "${var.country}"
  }

  allowed_uses = [
    "cert_signing",
  ]

  validity_period_hours = 87600
  is_ca_certificate     = true
}

#
# Self-signed certificate for Bastion WWW server
#
resource "tls_private_key" "bastion-web" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "bastion-web" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.bastion-web.private_key_pem}"

  subject {
    common_name         = "${length(var.bastion_host_name) == 0 ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}"
    organization        = "${var.company_name}"
    organizational_unit = "${var.organization_name}"
    locality            = "${var.locality}"
    province            = "${var.province}"
    country             = "${var.country}"
  }
}

resource "tls_locally_signed_cert" "bastion-web" {
  cert_request_pem = "${tls_cert_request.bastion-web.cert_request_pem}"

  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.root-ca-key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.root-ca.cert_pem}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "data_encipherment",
    "server_auth",
  ]
}
