#
# Ingress VPC resources
#

provider "aws" {
  alias  = "ingress"

  # If create is false then set default 
  # region as it is a required attribute
  region = "${var.create ? var.ingress_region : "us-east-1"}"
}

data "aws_vpc" "ingress-vpc" {
  provider = "aws.ingress"
  count    = "${var.create ? 1 : 0}"

  id = "${var.ingress_vpc_id}"
}

# Retrieve ingress VPC's admin subnet and route table

data "aws_subnet_ids" "ingress-admin" {
  provider = "aws.ingress"
  count    = "${var.create ? 1 : 0}"

  vpc_id = "${data.aws_vpc.ingress-vpc[0].id}"

  filter {
    name   = "tag:Name"
    values = ["*admin subnet*"]
  }
}

data "aws_subnet" "ingress-admin" {
  provider = "aws.ingress"
  count    = "${var.create ? length(data.aws_subnet_ids.ingress-admin[0].ids) : 0}"
  id       = "${element(flatten(data.aws_subnet_ids.ingress-admin[0].ids), count.index)}"
}

data "aws_route_tables" "ingress-admin" {
  provider = "aws.ingress"
  count    = "${var.create ? 1 : 0}"

  vpc_id = "${data.aws_vpc.ingress-vpc[0].id}"

  filter {
    name   = "tag:Name"
    values = [ "*admin route table*" ]
  }
}

# Retrieve ingress VPC's bastion instance's admin NIC

data "aws_network_interface" "ingress-bastion-nic" {
  provider = "aws.ingress"
  count    = "${var.create ? length(data.aws_subnet_ids.ingress-admin[0].ids) : 0}"

  filter {
    name   = "attachment.instance-id"
    values = [ "${var.ingress_bastion_id}" ]
  }
  filter {
    name   = "subnet-id"
    values = [ "${element(flatten(data.aws_subnet_ids.ingress-admin[0].ids), count.index)}" ]
  }
}
