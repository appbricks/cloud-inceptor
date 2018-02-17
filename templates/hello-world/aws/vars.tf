#
# Used for certificates creations
#

variable "company_name" {}
variable "organization_name" {}
variable "locality" {}
variable "province" {}
variable "country" {}

# VPC Name
variable "vpc_name" {}

# VPC DNS zone
variable "dns_zone_name" {}

#
# Concourse bootstrap pipeline
#

variable "bootstrap_pipeline_file" {
  default = ""
}

variable "bootstrap_var_file" {
  default = ""
}
