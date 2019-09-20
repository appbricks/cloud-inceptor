#
# Inceptor bastion common config module
# 
# When debugging replace source github path 
#
# - "github.com/appbricks/cloud-inceptor//modules/bastion-config"
#
# with relative path filesystem path.
#
# - "../../../modules/bastion-config"
#

module "config" {
  source = "../../../modules/bastion-config"

  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  root_ca_key  = "${var.root_ca_key}"
  root_ca_cert = "${var.root_ca_cert}"

  vpc_name                 = "${var.vpc_name}"
  vpc_cidr                 = "${var.vpc_cidr}"
  vpc_dns_zone             = "${var.vpc_dns_zone}"
  vpc_internal_dns_zones   = "${var.vpc_internal_dns_zones}"
  vpc_internal_dns_records = "${concat(var.vpc_internal_dns_records, list(local.jumpbox_dns_record))}"

  ssh_key_file_path = "${var.ssh_key_file_path}"

  bastion_fqdn      = "${var.vpc_dns_zone}"
  bastion_use_fqdn  = "${var.bastion_use_fqdn}"
  bastion_public_ip = "${google_compute_address.bastion-public.address}"

  bastion_dns = "${length(var.bastion_dns) == 0 ? google_compute_subnetwork.admin.gateway_address: var.bastion_dns}"

  bastion_dmz_itf_ip   = "${google_compute_address.bastion-dmz.address}"
  bastion_admin_itf_ip = "${google_compute_address.bastion-admin.address}"

  bastion_nic_config = [
    "${join("|", 
      list(
        "", // GCP will assign static IP via DHCP
        google_compute_subnetwork.dmz.ip_cidr_range,
        "0.0.0.0/0"
      ),
    )}",
    "${join("|", 
      list(
        google_compute_address.bastion-admin.address, 
        google_compute_subnetwork.admin.ip_cidr_range,
        var.vpc_cidr,
        google_compute_subnetwork.admin.gateway_address
      )
    )}",
  ]

  data_volume_name = "sdb"

  bastion_admin_ssh_port = "${var.bastion_admin_ssh_port}"
  bastion_admin_user     = "${var.bastion_admin_user}"
  squidproxy_server_port = "${var.squidproxy_server_port}"

  vpn_server_port        = "${var.vpn_server_port}"
  vpn_protocol           = "${var.vpn_protocol}"
  vpn_network            = "${var.vpn_network}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_users              = "${var.vpn_users}"

  smtp_relay_host    = "${var.smtp_relay_host}"
  smtp_relay_port    = "${var.smtp_relay_port}"
  smtp_relay_api_key = "${var.smtp_relay_api_key}"

  concourse_server_port    = "${var.concourse_server_port}"
  concourse_admin_password = "${var.concourse_admin_password}"
  bootstrap_pipeline_file  = "${var.bootstrap_pipeline_file}"

  pipeline_automation_path = "${var.pipeline_automation_path}"
  notification_email       = "${var.notification_email}"

  bootstrap_pipeline_vars = <<PIPELINE_VARS
---
${var.bootstrap_pipeline_vars}

# VPC Variables
environment: ${var.vpc_name}
region: ${var.region}
PIPELINE_VARS
}
