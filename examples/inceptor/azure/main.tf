#
# Bootstrap an base environment named "inceptor"
#

module "bootstrap" {
  source = "../../../modules/bootstrap/azure"

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
  region = "${var.region}"

  vpc_name = "inceptor-${var.region}"
  vpc_cidr = "${var.regional_vpc_cidr[var.region]["vpc_cidr"]}"

  # DNS Name for VPC will be 'test.azure.appbricks.cloud'
  vpc_dns_zone    = "test-${var.region}.azure.appbricks.cloud"
  attach_dns_zone = "${var.bastion_use_fqdn}"

  # Local DNS zone. This could also be the same as the public
  # which will enable setting up a split DNS of the public zone
  # for names to map to external and internal addresses.
  vpc_internal_dns_zones = ["appbricks.local"]

  # VPN
  # vpn_idle_action = "shutdown"

  vpn_users = [
    "user1|P@ssw0rd1",
    "user2|P@ssw0rd2"
  ]

  # vpn_type = "ipsec"
  vpn_type = "openvpn"
  vpn_tunnel_all_traffic = "yes"
  ovpn_server_port = "2295"
  ovpn_protocol = "udp"

  # Tunnel for VPN to handle situations where 
  # OpenVPN is blocked or throttled by ISP
  # tunnel_vpn_port_start = "2296"
  # tunnel_vpn_port_end   = "3396"

  # Concourse Port
  concourse_server_port = "8080"

  # Whether to allow SSH access to bastion server
  bastion_allow_public_ssh = true

  bastion_host_name = "inceptor"
  bastion_use_fqdn = "${var.bastion_use_fqdn}"

  bastion_use_managed_image             = var.bastion_use_managed_image
  bastion_image_name                    = var.bastion_image_name
  bastion_image_storage_account_prefix  = var.bastion_image_storage_account_prefix

  # Issue certificates from letsencrypt.org
  certify_bastion = false

  # ICMP needs to be allowed to enable ICMP tunneling
  allow_bastion_icmp = true
  
  # If the SMTP relay settings are provided then
  # and SMTP server will be setup which will send
  # notifications when builds fail
  smtp_relay_host = "${var.smtp_relay_host}"

  smtp_relay_port    = "${var.smtp_relay_port}"
  smtp_relay_api_key = "${var.smtp_relay_api_key}"

  notification_email = "${var.notification_email}"

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
  filename = "${path.module}/.${var.region}/bastion-admin-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${path.module}/.${var.region}/bastion-admin-ssh-key.pem"
  }
}

resource "local_file" "default-ssh-key" {
  content  = module.bootstrap.default_openssh_private_key
  filename = "${path.module}/.${var.region}/default-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${path.module}/.${var.region}/default-ssh-key.pem"
  }
}

#
# Limit version of Azure provider to avoid image copy issue
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/4361
#
provider "azurerm" {
  version = "< 1.34.0"
}

#
# Backend state
#
terraform {
  backend "azurerm" {
    resource_group_name  = "default"
    container_name       = "test"
    key                  = "terraform.tfstate"
  }
}

# ==== DEBUG OUTPUT ====

# output "debug_output" {
#   value = "${module.bootstrap.debug_output}"
# }
