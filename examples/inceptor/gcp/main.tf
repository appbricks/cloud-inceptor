#
# Bootstrap an base environment named "inceptor"
#

module "bootstrap" {
  source = "../../../modules/bootstrap/gcp"

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
  region = "europe-west4"

  vpc_name = "inceptor"

  # DNS Name for VPC will be 'test.gcp.appbricks.cloud'
  vpc_dns_zone = "test.gcp.appbricks.cloud"

  # Name of parent zone 'gcp.appbricks.cloud' to which the 
  # name server records of the 'vpc_dns_zone' will be added.
  dns_managed_zone_name = "gcp-appbricks-cloud"

  # Local file path to write SSH private key for bastion instance
  ssh_key_file_path = "${path.module}"

  #
  # Bootstrap pipeline
  #
  bootstrap_pipeline_file = "../../../pipelines/bootstrap-greeting/pipeline.yml"

  bootstrap_pipeline_vars = <<PIPELINE_VARS
locale: Asia/Dubai
PIPELINE_VARS
}

#
# Backend state
#
terraform {
  backend "gcs" {
    bucket = "tfstate-europe-west1"
    prefix = "test/cloud-inceptor"
  }
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

output "vpn_admin_password" {
  value = "${module.bootstrap.vpn_admin_password}"
}

output "concourse_admin_password" {
  value = "Passw0rd"
}
