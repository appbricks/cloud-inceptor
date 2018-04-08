#
# Inception bastion instance configuration
#
# When debugging replace source github path
#
# - "github.com/appbricks/cloud-inceptor//modules/inception/gcp"
# 
# with relative path filesystem path.
#
# - "../../inception/gcp"
#

module "inception" {
  source = "../../inception/gcp"

  region = "${var.region}"

  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  root_ca_key  = "${var.root_ca_key}"
  root_ca_cert = "${var.root_ca_cert}"

  vpc_name     = "${var.vpc_name}"
  vpc_dns_zone = "${var.vpc_dns_zone}"
  vpc_cidr     = "${var.vpc_cidr}"

  dmz_network             = "${google_compute_network.dmz.self_link}"
  dmz_subnetwork          = "${google_compute_subnetwork.dmz.self_link}"
  dmz_subnetwork_cidr     = "${google_compute_subnetwork.dmz.ip_cidr_range}"
  mgmt_network            = "${google_compute_network.mgmt.self_link}"
  mgmt_subnetwork         = "${google_compute_subnetwork.mgmt.self_link}"
  mgmt_subnetwork_cidr    = "${google_compute_subnetwork.mgmt.ip_cidr_range}"
  mgmt_subnetwork_gateway = "${google_compute_subnetwork.mgmt.gateway_address}"

  ssh_key_file_path = "${var.ssh_key_file_path}"

  bastion_instance_type            = "${var.bastion_instance_type}"
  bastion_image_name               = "${var.bastion_image_name}"
  bastion_root_disk_size           = "${var.bastion_root_disk_size}"
  bastion_concourse_vols_disk_size = "${var.bastion_concourse_vols_disk_size}"
  bastion_host_name                = "${var.bastion_host_name}"
  bastion_use_fqdn                 = "${var.bastion_use_fqdn}"

  bastion_admin_ssh_port = "${var.bastion_admin_ssh_port}"
  squidproxy_server_port = "${var.squidproxy_server_port}"

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
