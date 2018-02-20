#
# Inceptor Common Module
#

module "common" {
  source = "../../common"

  vpc_name     = "${var.vpc_name}"
  vpc_dns_zone = "${var.vpc_dns_zone}"

  ssh_key_file_path = "${var.ssh_key_file_path}"

  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  bastion_fqdn      = "${length(var.bastion_host_name) == 0 ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}"
  bastion_use_fqdn  = "${var.bastion_use_fqdn}"
  bastion_public_ip = "${google_compute_address.bastion-public.address}"

  bastion_nic1_private_ip = "${google_compute_address.bastion-dmz.address}"
  bastion_nic1_netmask    = "${cidrnetmask(google_compute_subnetwork.dmz.ip_cidr_range)}"
  bastion_nic1_lan_cidr   = "${google_compute_subnetwork.dmz.ip_cidr_range}"

  bastion_nic2_private_ip  = "${google_compute_address.bastion-engineering.address}"
  bastion_nic2_netmask     = "${cidrnetmask(google_compute_subnetwork.engineering.ip_cidr_range)}"
  bastion_nic2_lan_cidr    = "${var.vpc_cidr}"
  bastion_nic2_lan_netmask = "${cidrnetmask(var.vpc_cidr)}"
  bastion_nic2_lan_gateway = "${cidrhost(google_compute_subnetwork.engineering.ip_cidr_range, 1)}"

  squidproxy_server_port = "${var.squidproxy_server_port}"

  vpn_server_port        = "${var.vpn_server_port}"
  vpn_protocol           = "${var.vpn_protocol}"
  vpn_network            = "${var.vpn_network}"
  vpn_network_dns        = "${length(var.vpn_network_dns) == 0 ? cidrhost(google_compute_subnetwork.engineering.ip_cidr_range, 1): var.vpn_network_dns}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_users              = "${var.vpn_users}"

  concourse_server_port    = "${var.concourse_server_port}"
  concourse_admin_password = "${var.concourse_admin_password}"
  bootstrap_pipeline_file  = "${var.bootstrap_pipeline_file}"
  bootstrap_var_file       = "${var.bootstrap_var_file}"
}

output "bastion_fqdn" {
  value = "${length(var.bastion_host_name) == 0 ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}"
}

output "vpn_admin_password" {
  value = "${module.common.vpn_admin_password}"
}
