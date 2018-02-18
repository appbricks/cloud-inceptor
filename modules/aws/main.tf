#
# AWS Virtual Private Cloud
#

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.vpc_name}"
  }
}

#
# Availability Zones in current region
#

data "aws_availability_zones" "available" {}

#
# Outputs
#

output "vpc-id" {
  value = "${aws_vpc.main.id}"
}

output "vpc-cidr" {
  value = "${aws_vpc.main.cidr_block}"
}

output "vpc-available-subnet" {
  # This module creates 2 subnets for each  AZs
  value = "${var.subnet_start + (length(data.aws_availability_zones.available.names)*2)}"
}
