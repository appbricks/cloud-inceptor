#
# Egress VPC resources
#

provider "aws" {
  alias  = "egress"

  # If create is false then set default 
  # region as it is a required attribute
  region = "${var.create ? var.egress_region : "us-east-1"}"
}

data "aws_vpc" "egress-vpc" {
  provider = "aws.egress"
  count    = "${var.create ? 1 : 0}"

  id = "${var.egress_vpc_id}"
}

# Retrieve egress VPC's admin subnets

data "aws_subnet_ids" "egress-admin" {
  provider = "aws.egress"
  count    = "${var.create ? 1 : 0}"

  vpc_id = "${data.aws_vpc.egress-vpc[0].id}"

  filter {
    name   = "tag:Name"
    values = ["*admin subnet*"]
  }
}

data "aws_subnet" "egress-admin" {
  provider = "aws.egress"
  count    = "${var.create ? length(data.aws_subnet_ids.egress-admin[0].ids) : 0}"
  id       = "${element(flatten(data.aws_subnet_ids.egress-admin[0].ids), count.index)}"
}

data "aws_route_tables" "egress-admin" {
  provider = "aws.egress"
  count    = "${var.create ? 1 : 0}"

  vpc_id = "${data.aws_vpc.egress-vpc[0].id}"

  filter {
    name   = "tag:Name"
    values = [ "*admin route table*" ]
  }
}

# Retrieve egress VPC's bastion instance's admin NIC

data "aws_network_interface" "egress-bastion-nic" {
  provider = "aws.egress"
  count    = "${var.create ? length(data.aws_subnet_ids.egress-admin[0].ids) : 0}"

  filter {
    name   = "attachment.instance-id"
    values = [ "${var.egress_bastion_id}" ]
  }
  filter {
    name   = "subnet-id"
    values = [ "${element(flatten(data.aws_subnet_ids.egress-admin[0].ids), count.index)}" ]
  }
}
