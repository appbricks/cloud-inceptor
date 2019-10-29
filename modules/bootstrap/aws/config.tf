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

  certify_bastion   = "${var.certify_bastion}"
  bastion_fqdn      = "${var.vpc_dns_zone}"
  bastion_use_fqdn  = "${var.bastion_use_fqdn}"
  bastion_public_ip = "${aws_eip.bastion-public.public_ip}"

  bastion_dns = "${length(var.bastion_dns) == 0 ? cidrhost(var.vpc_cidr, 2): var.bastion_dns}"

  bastion_dmz_itf_ip   = "${local.bastion_dmz_itf_ip}"
  bastion_admin_itf_ip = "${local.bastion_admin_itf_ip}"

  bastion_nic_config = [
    "${join("|", 
      list(
        "", // AWS will assign static IP via DHCP
        aws_subnet.dmz[0].cidr_block,
        "0.0.0.0/0"
      ),
    )}",
    "${join("|", 
      list(
        local.bastion_admin_itf_ip, 
        aws_subnet.admin[0].cidr_block,
        length(var.global_internal_cidr) == 0 ? var.vpc_cidr : var.global_internal_cidr,
        cidrhost(aws_subnet.admin[0].cidr_block, 1)
      )
    )}",
  ]

  data_volume_name = "${local.bastion_data_disk_device_name}"

  bastion_admin_ssh_port = "${var.bastion_admin_ssh_port}"
  bastion_admin_user     = "${var.bastion_admin_user}"
  squidproxy_server_port = "${var.squidproxy_server_port}"

  vpn_type               = "${var.vpn_type}"
  vpn_network            = "${var.vpn_network}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_idle_action        = "${var.vpn_idle_action}"
  vpn_users              = "${join(",", var.vpn_users)}"

  ovpn_server_port = "${var.ovpn_server_port}"
  ovpn_protocol    = "${var.ovpn_protocol}"

  tunnel_vpn_port_start = "${var.tunnel_vpn_port_start}"
  tunnel_vpn_port_end   = "${var.tunnel_vpn_port_end}"

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
