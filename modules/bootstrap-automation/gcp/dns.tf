#
# Hosted zone for VPC
#

data "google_dns_managed_zone" "parent" {
  name = "${var.dns_managed_zone_name}"
}

#
# Public Zone
#
resource "google_dns_managed_zone" "vpc" {
  name     = "${replace("${var.vpc_dns_zone}", ".", "-")}"
  dns_name = "${var.vpc_dns_zone}."
}

resource "google_dns_record_set" "vpc" {
  name         = "${var.vpc_dns_zone}."
  managed_zone = "${data.google_dns_managed_zone.parent.name}"

  type = "NS"
  ttl  = 300

  rrdatas = [
    "${google_dns_managed_zone.vpc.name_servers.0}",
    "${google_dns_managed_zone.vpc.name_servers.1}",
    "${google_dns_managed_zone.vpc.name_servers.2}",
    "${google_dns_managed_zone.vpc.name_servers.3}",
  ]
}

#
# Bastion instance DNS
#
resource "google_dns_record_set" "bastion-admin" {
  name         = "admin-${local.bastion_fqdn}."
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${var.bastion_allow_public_ssh == "false" ? google_compute_address.bastion-admin.address : google_compute_address.bastion-public.address}"]
}

resource "google_dns_record_set" "bastion-public" {
  name         = "${local.bastion_fqdn}."
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${google_compute_address.bastion-public.address}"]
}
