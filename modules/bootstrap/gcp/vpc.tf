#
# Pave VPC with the foundation network architecture and resources
# 
# When debugging replace source github path 
#
# - "github.com/appbricks/cloud-inceptor//modules/network/gcp"
#
# with relative path filesystem path.
#
# - "../../../modules/network/gcp"
#

module "vpc" {
  source = "github.com/appbricks/cloud-inceptor//modules/network/gcp"

  region           = "${var.region}"
  vpc_name         = "${var.vpc_name}"
  vpc_dns_zone     = "${var.vpc_dns_zone}"
  vpc_cidr         = "${var.vpc_cidr}"
  vpc_subnet_bits  = "${var.vpc_subnet_bits}"
  vpc_subnet_start = "${var.vpc_subnet_start}"
  dmz_cidr         = "${var.dmz_cidr}"
  max_azs          = "${var.max_azs}"

  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  bastion_host_name = "${var.bastion_host_name}"

  vpn_server_port        = "${var.vpn_server_port}"
  vpn_protocol           = "${var.vpn_protocol}"
  vpn_network            = "${var.vpn_network}"
  vpn_network_dns        = "${var.vpn_network_dns}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_users              = "${var.vpn_users}"

  concourse_server_port    = "${var.concourse_server_port}"
  concourse_admin_password = "${var.concourse_admin_password}"
  bootstrap_pipeline_file  = "${var.bootstrap_pipeline_file}"
  bootstrap_pipeline_vars  = "${var.bootstrap_pipeline_vars}"
}

resource "google_dns_record_set" "bastion-private" {
  name         = "admin-${module.vpc.bastion_fqdn}."
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${module.vpc.bastion_private_ip}"]
}

resource "google_dns_record_set" "bastion-public" {
  name         = "${module.vpc.bastion_fqdn}."
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${module.vpc.bastion_public_ip}"]
}

output "bastion_fqdn" {
  value = "${google_dns_record_set.bastion-public.name}"
}

output "bastion_admin_fqdn" {
  value = "${google_dns_record_set.bastion-private.name}"
}

output "vpn_admin_password" {
  value = "${module.vpc.vpn_admin_password}"
}

output "concourse_admin_password" {
  value = "${var.concourse_admin_password}"
}
