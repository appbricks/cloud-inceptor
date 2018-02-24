#
# Inceptor bastion common config module
# 
# When debugging replace source github path 
# with relative path filesystem path.
#
# - "../../../modules/network/gcp"
#

module "config" {
  source = "github.com/appbricks/cloud-inceptor//modules/bastion-config"

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
  bastion_nic1_netmask    = "${cidrnetmask(var.dmz_subnetwork_cidr)}"
  bastion_nic1_lan_cidr   = "${var.dmz_subnetwork_cidr}"

  bastion_nic2_private_ip  = "${google_compute_address.bastion-engineering.address}"
  bastion_nic2_netmask     = "${cidrnetmask(var.engineering_subnetwork_cidr)}"
  bastion_nic2_lan_cidr    = "${var.vpc_cidr}"
  bastion_nic2_lan_netmask = "${cidrnetmask(var.vpc_cidr)}"
  bastion_nic2_lan_gateway = "${var.engineering_subnetwork_gateway}"

  squidproxy_server_port = "${var.squidproxy_server_port}"

  vpn_server_port        = "${var.vpn_server_port}"
  vpn_protocol           = "${var.vpn_protocol}"
  vpn_network            = "${var.vpn_network}"
  vpn_network_dns        = "${length(var.vpn_network_dns) == 0 ? var.engineering_subnetwork_gateway: var.vpn_network_dns}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_users              = "${var.vpn_users}"

  concourse_server_port    = "${var.concourse_server_port}"
  concourse_admin_password = "${var.concourse_admin_password}"
  bootstrap_pipeline_file  = "${var.bootstrap_pipeline_file}"
  bootstrap_var_file       = "${var.bootstrap_var_file}"
}