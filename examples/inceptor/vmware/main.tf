#
# VSphere Environment
#

variable "datacenter" {
  type = "string"
}

variable "clusters" {
  type = "list"
}

variable "ephemeral_datastore" {
  type = "string"
}

variable "persistent_datastore" {
  type = "string"
}

variable "dmz_network" {
  type = "string"
}

variable "dmz_network_cidr" {
  type = "string"
}

variable "dmz_network_gateway" {
  type = "string"
}

variable "admin_network" {
  type = "string"
}

variable "admin_network_cidr" {
  type = "string"
}

variable "admin_network_gateway" {
  type = "string"
}

#
# Notifications
#

variable "smtp_relay_host" {
  default = ""
}

variable "smtp_relay_port" {
  default = ""
}

variable "smtp_relay_api_key" {
  default = ""
}

variable "notification_email" {
  default = ""
}

#
# Bootstrap an base environment named "inceptor"
#

module "bootstrap" {
  source = "../../../modules/bootstrap-automation/vmware"

  #
  # Company information used in certificate creation
  #
  company_name = "appbricks"

  organization_name = "appbricks dev"

  locality = "Boston"

  province = "MA"

  country = "US"

  #
  # VMware IaaS configuration
  #
  datacenter = "${var.datacenter}"

  clusters = ["${var.clusters}"]

  ephemeral_datastore  = "${var.ephemeral_datastore}"
  persistent_datastore = "${var.persistent_datastore}"

  dmz_network         = "${var.dmz_network}"
  dmz_network_cidr    = "${var.dmz_network_cidr}"
  dmz_network_gateway = "${var.dmz_network_gateway}"

  admin_network         = "${var.admin_network}"
  admin_network_cidr    = "${var.admin_network_cidr}"
  admin_network_gateway = "${var.admin_network_gateway}"

  vpc_name     = "inceptor"
  vpc_dns_zone = "test.vmw.appbricks.cloud"
  vpc_cidr     = "${var.admin_network_cidr}"

  # Local DNS zone. This could also be the same as the public
  # which will enable setting up a split DNS of the public zone
  # for names to map to external and internal addresses.
  vpc_internal_dns_zones = ["appbricks.local"]

  # Local file path to write SSH private key for bastion instance
  ssh_key_file_path = "${path.module}"

  # VPN Port
  vpn_server_port = "2295"

  # Concourse Port
  concourse_server_port = "8080"

  # Bastion services exposed via IP
  bastion_use_fqdn = "false"

  # Whether to allow SSH access to bastion server
  bastion_allow_public_ssh = "true"
  bastion_dmz_ip           = "${cidrhost(var.dmz_network_cidr, 20)}"
  bastion_admin_ip         = "${cidrhost(var.admin_network_cidr, 5)}"

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
  deploy_jumpbox = "true"

  jumpbox_admin_ip = "${cidrhost(var.admin_network_cidr, 10)}"

  #
  # Bootstrap pipeline
  #
  bootstrap_pipeline_file = "../../../pipelines/bootstrap-greeting/pipeline.yml"

  bootstrap_pipeline_vars = <<PIPELINE_VARS
locale: Asia/Dubai
PIPELINE_VARS
}

#
# Echo output of bootstrap module
#

output "bastion_fqdn" {
  value = "${module.bootstrap.bastion_fqdn}"
}

output "bastion_admin_fqdn" {
  value = "${module.bootstrap.bastion_admin_fqdn}"
}

output "bastion_admin_password" {
  value = "${module.bootstrap.bastion_admin_password}"
}

output "concourse_admin_password" {
  value = "Passw0rd"
}
