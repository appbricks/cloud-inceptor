#
# Inceptor bastion common config module
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

  bastion_fqdn      = "${var.vpc_dns_zone}"
  bastion_use_fqdn  = "${var.bastion_use_fqdn}"
  bastion_public_ip = "${local.bastion_public_ip}"

  bastion_dns = "${var.bastion_dns}"

  enable_bastion_as_dhcpd = "${var.enable_bastion_as_dhcpd}"
  dhcpd_lease_range       = "${var.dhcpd_lease_range}"

  # Assume the first NIC config is the external interface 
  bastion_dmz_itf_ip   = "${local.bastion_dmz_itf_ip}"
  bastion_admin_itf_ip = "${local.bastion_admin_itf_ip}"
  bastion_nic_config   = "${data.external.bastion-nic-config.*.result.config}"

  data_volume_name = "/dev/sdb"

  bastion_admin_ssh_port   = "${var.bastion_admin_ssh_port}"
  bastion_admin_user       = "${var.bastion_admin_user}"
  squidproxy_server_port   = "${var.squidproxy_server_port}"
  smtp_relay_host          = "${var.smtp_relay_host}"
  smtp_relay_port          = "${var.smtp_relay_port}"
  smtp_relay_api_key       = "${var.smtp_relay_api_key}"
  concourse_server_port    = "${var.concourse_server_port}"
  concourse_admin_password = "${var.concourse_admin_password}"
  bootstrap_pipeline_file  = "${var.bootstrap_pipeline_file}"

  vpn_type               = "${var.vpn_type}"
  vpn_network            = "${var.vpn_network}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_idle_action        = "${var.vpn_idle_action}"
  vpn_users              = "${join(",", var.vpn_users)}"

  ovpn_service_port = "${var.ovpn_service_port}"
  ovpn_protocol     = "${var.ovpn_protocol}"

  tunnel_vpn_port_start = "${var.tunnel_vpn_port_start}"
  tunnel_vpn_port_end   = "${var.tunnel_vpn_port_end}"

  pipeline_automation_path = "${var.pipeline_automation_path}"
  notification_email       = "${var.notification_email}"

  bootstrap_pipeline_vars = <<PIPELINE_VARS
---
${var.bootstrap_pipeline_vars}

# VPC Variables
environment: ${var.vpc_name}

PIPELINE_VARS
}
