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
  datacenter = "lab"

  clusters  = ["cl01"]
  datastore = "datastore1"

  dmz_network         = "VM Network"
  dmz_network_cidr    = "192.168.100.0/24"
  dmz_network_gateway = "192.168.100.2"

  admin_network      = "Admin Network"
  admin_network_cidr = "192.168.101.0/24"

  vpc_name     = "inceptor"
  vpc_dns_zone = "test.vmw.appbricks.cloud"
  vpc_cidr     = "192.168.101.0/24"

  # Local file path to write SSH private key for bastion instance
  ssh_key_file_path = "${path.module}"

  # VPN Port
  vpn_server_port = "2295"

  # Concourse Port
  concourse_server_port = "8080"

  # Whether to allow SSH access to bastion server
  bastion_allow_public_ssh = "true"

  bastion_dmz_ip   = "192.168.100.20"
  bastion_admin_ip = "192.168.101.5"

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

output "bastion_admin_password" {
  value = "${module.bootstrap.bastion_admin_password}"
}

output "concourse_admin_password" {
  value = "Passw0rd"
}
