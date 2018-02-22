#
# AWS Virtual Private Cloud
#
data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}

#
# Availability Zones in current region
#

data "aws_availability_zones" "available" {}
