#
# Bootstrap an base environment named "inceptor"
#

module "bootstrap" {
  source = "../../../templates/bootstrap/aws"

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
  vpc_name = "inceptor"

  vpc_dns_zone = "test.aws.appbricks.cloud"

  #
  # Bootstrap pipeline
  #
  bootstrap_pipeline_file = "../../../pipelines/bootstrap-hello-world/pipeline.yml"
}

#
# Backend state
#
terraform {
  backend "s3" {
    bucket = "appbricks-use1-tf-states"
    key    = "test/cloud-inceptor"
  }
}

#
# Echo output of bootstrap module
#
output "bastion_fqdn" {
  value = "${module.bootstrap.bastion_fqdn}"
}

output "bastion_admin_fqdn" {
  value = "${module.bootstrap.bastion_fqdn}"
}

output "vpn_admin_password" {
  value = "${module.bootstrap.vpn_admin_password}"
}

output "concourse_admin_password" {
  value = "${module.bootstrap.concourse_admin_password}"
}
