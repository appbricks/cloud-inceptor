# AWS region from environment
data "aws_region" "default" {
}

locals {
  vpc_cidr = var.regional_vpc_cidr[data.aws_region.default.name]["vpc_cidr"]
  vpc_subnet_index = element(regex("\\d{1,3}\\.(\\d{1,3})\\.\\d{1,3}\\.\\d{1,3}\\/\\d+", local.vpc_cidr), 0)
}

#
# Bootstrap a base environment named "inceptor"
#
module "bootstrap" {
  source = "../../../modules/bootstrap/aws"

  mycs_node_private_key = var.mycs_node_private_key
  mycs_node_id_key = var.mycs_node_id_key

  #
  # Company information used in certificate creation
  #
  company_name = "appbricks"

  organization_name = "appbricks dev"

  locality = "Boston"

  province = "MA"

  country = "US"

  #
  # VPC details
  #
  region = data.aws_region.default.name

  vpc_name = "inceptor-${data.aws_region.default.name}"
  vpc_cidr = local.vpc_cidr

  configure_admin_network = var.configure_admin_network

  # DNS Name for VPC will be 'test-<region>.aws.appbricks.io'
  vpc_dns_zone    = "test-${data.aws_region.default.name}.aws.appbricks.io"
  attach_dns_zone = var.attach_dns_zone

  # Local DNS zone. This could also be the same as the public
  # which will enable setting up a split DNS of the public zone
  # for names to map to external and internal addresses.
  vpc_internal_dns_zones = ["test-${data.aws_region.default.name}.local"]

  # Address space for all VPC regions
  global_internal_cidr = "172.16.0.0/12"

  # VPN
  # vpn_idle_action = "shutdown"

  vpn_users = [
    "user1|P@ssw0rd1",
    "user2|P@ssw0rd2"
  ]

  vpn_type = "ipsec"

  # vpn_type          = "openvpn"
  # ovpn_service_port = "2295"
  # ovpn_protocol     = "udp"

  # vpn_type               = "wireguard"
  # wireguard_service_port = "3399"

  # wireguard mesh of cloud space peers
  wireguard_mesh_node = local.vpc_subnet_index

  # Tunnel for VPN to handle situations where 
  # OpenVPN is blocked or throttled by ISP
  # tunnel_vpn_port_start = "2296"
  # tunnel_vpn_port_end   = "3396"

  vpn_tunnel_all_traffic = "yes"

  # Concourse Port
  # concourse_server_port = "8080"

  # Whether to allow SSH access to bastion server
  bastion_allow_public_ssh = true

  bastion_host_name = "inceptor"
  bastion_use_fqdn = var.attach_dns_zone

  bastion_instance_type = "t4g.micro"

  bastion_image_name  = var.bastion_image_name
  bastion_image_owner = var.bastion_image_owner

  # Issue certificates from letsencrypt.org
  certify_bastion = false

  # ICMP needs to be allowed to enable ICMP tunneling
  allow_bastion_icmp = true

  # If the SMTP relay settings are provided then
  # and SMTP server will be setup which will send
  # notifications when builds fail
  smtp_relay_host = var.smtp_relay_host

  smtp_relay_port    = var.smtp_relay_port
  smtp_relay_api_key = var.smtp_relay_api_key

  notification_email = var.notification_email

  # Whether to deploy a jumpbox in the admin network. The
  # jumpbox will be deployed only if a local DNS zone is
  # provided and the DNS will be jumpbox.[first local zone].
  deploy_jumpbox = true

  #
  # Bootstrap pipeline
  #
  bootstrap_pipeline_file = "../../../pipelines/bootstrap-greeting/pipeline.yml"

  bootstrap_pipeline_vars = <<PIPELINE_VARS
locale: Asia/Dubai
PIPELINE_VARS
}

#
# SSH Keys
#

resource "local_file" "bastion-ssh-key" {
  content  = module.bootstrap.bastion_admin_sshkey
  filename = "${path.module}/.${data.aws_region.default.name}/bastion-admin-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${path.module}/.${data.aws_region.default.name}/bastion-admin-ssh-key.pem"
  }
}

resource "local_file" "default-ssh-key" {
  content  = module.bootstrap.default_openssh_private_key
  filename = "${path.module}/.${data.aws_region.default.name}/default-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${path.module}/.${data.aws_region.default.name}/default-ssh-key.pem"
  }
}

#
# Backend state
#
terraform {
  backend "s3" {
    key = "test/cloud-inceptor"
  }
}
