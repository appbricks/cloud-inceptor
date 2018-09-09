#
# Module local variables
#

locals {
  bastion_fqdn = "${length(var.bastion_host_name) == 0 
    ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}"
}
