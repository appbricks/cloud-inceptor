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

module "network" {
  source = "../../../modules/network/gcp"

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

  ssh_key_file_path = "${var.ssh_key_file_path}"

  bastion_instance_type            = "${var.bastion_instance_type}"
  bastion_root_disk_size           = "${var.bastion_root_disk_size}"
  bastion_concourse_vols_disk_size = "${var.bastion_concourse_vols_disk_size}"
  bastion_host_name                = "${var.bastion_host_name}"

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
  name         = "admin-${module.network.bastion_fqdn}."
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${module.network.bastion_private_ip}"]
}

resource "google_dns_record_set" "bastion-public" {
  name         = "${module.network.bastion_fqdn}."
  managed_zone = "${google_dns_managed_zone.vpc.name}"

  type    = "A"
  ttl     = "300"
  rrdatas = ["${module.network.bastion_public_ip}"]
}
