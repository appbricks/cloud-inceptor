#
# Google Cloud DNS
#

data "google_dns_managed_zone" "parent" {
  count    = local.use_google ? 1 : 0
  dns_name = local.google_parent_dns_name
}

resource "google_dns_managed_zone" "vpc" {
  count = local.use_google ? 1 : 0

  name     = replace(var.vpc_dns_zone, ".", "-")
  dns_name = "${var.vpc_dns_zone}."
}

resource "google_dns_record_set" "vpc_ns" {
  count = local.use_google ? 1 : 0

  name         = "${var.vpc_dns_zone}."
  managed_zone = data.google_dns_managed_zone.parent[0].name

  type = "NS"
  ttl  = 300

  rrdatas = [
    google_dns_managed_zone.vpc[0].name_servers[0],
    google_dns_managed_zone.vpc[0].name_servers[1],
    google_dns_managed_zone.vpc[0].name_servers[2],
    google_dns_managed_zone.vpc[0].name_servers[3],
  ]
}

resource "google_dns_record_set" "vpc_public" {
  count = local.use_google ? 1 : 0

  name         = "${var.vpc_dns_zone}."
  managed_zone = google_dns_managed_zone.vpc[0].name

  type    = "A"
  ttl     = "300"
  rrdatas = [var.bastion_public_ip]
}

resource "google_dns_record_set" "vpc_admin" {
  count = (
    local.use_google
    && length(var.bastion_host_name) > 0
    && !var.bastion_allow_public_ssh
  ) ? 1 : 0

  name         = "${var.bastion_host_name}.${var.vpc_dns_zone}."
  managed_zone = google_dns_managed_zone.vpc[0].name

  type    = "A"
  ttl     = "300"
  rrdatas = [var.bastion_admin_itf_ip]
}

resource "google_dns_record_set" "vpc_mail" {
  count = local.use_google && length(var.smtp_relay_host) > 0 ? 1 : 0

  name         = "mail.${var.vpc_dns_zone}."
  managed_zone = google_dns_managed_zone.vpc[0].name

  type    = "A"
  ttl     = "300"
  rrdatas = [var.bastion_admin_itf_ip]
}

resource "google_dns_record_set" "vpc_mx" {
  count = local.use_google && length(var.smtp_relay_host) > 0 ? 1 : 0

  name         = "${var.vpc_dns_zone}."
  managed_zone = google_dns_managed_zone.vpc[0].name

  type    = "MX"
  ttl     = "300"
  rrdatas = ["1 ${google_dns_record_set.vpc_public[0].name}"]
}

resource "google_dns_record_set" "vpc_txt" {
  count = local.use_google && length(var.smtp_relay_host) > 0 ? 1 : 0

  name         = "${var.vpc_dns_zone}."
  managed_zone = google_dns_managed_zone.vpc[0].name

  type    = "TXT"
  ttl     = "300"
  rrdatas = ["\"v=spf1 mx -all\""]
}
