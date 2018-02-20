#
# Pave VPC with the foundation network architecture and resources
# 

module "vpc" {
  source = "../../../modules/iaas/gcp"

  region = "${var.region}"

  vpc_name     = "${var.vpc_name}"
  vpc_dns_zone = "${var.vpc_dns_zone}"
  vpc_cidr     = "${var.vpc_cidr}"

  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  vpn_server_port        = "${var.vpn_server_port}"
  vpn_protocol           = "${var.vpn_protocol}"
  vpn_network            = "${var.vpn_network}"
  vpn_network_dns        = "${var.vpn_network_dns}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_users              = "${var.vpn_users}"

  bootstrap_pipeline_file = "${var.bootstrap_pipeline_file}"
  bootstrap_var_file      = "${var.bootstrap_var_file}"
}

resource "google_dns_record_set" "bastion-public" {
  name         = "${module.vpc.bastion_fqdn}."
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${module.vpc.bastion-public-ip}"]
}

resource "google_dns_record_set" "bastion-private" {
  name         = "admin-${module.vpc.bastion_fqdn}."
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${module.vpc.bastion-private-ip}"]
}

output "bastion-fqdn" {
  value = "${google_dns_record_set.bastion-public.name}"
}

output "bastion-admin-fqdn" {
  value = "${google_dns_record_set.bastion-private.name}"
}

output "vpn_admin_password" {
  value = "${module.vpc.vpn_admin_password}"
}
