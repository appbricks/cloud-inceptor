#
# AWS Connection
#
provider "aws" {}

#
# Backend state
#
terraform {
  backend "s3" {
    bucket = "appbricks-use1-tf-states"
    key    = "test/cloud-inceptor"
  }
}
