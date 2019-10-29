#
# Egress
#

variable "peer_node_region" {
  default = ""
}

locals {
  peer_node = "${length(var.peer_node_region) != 0 ? true : false}"
  
  peer_node_state_bucket = "tfstate-${var.peer_node_region}"
}

#
# Peer egress VPC 
#

data "terraform_remote_state" "peer-node" {
  count   = "${local.peer_node ? 1 : 0}"
  backend = "s3"

  config = {
    key    = "test/cloud-inceptor"
    bucket = "${local.peer_node_state_bucket}"
    region = "${var.peer_node_region}"
  }
}

module "peer-node" {
  source = "../../../modules/peer-node/aws"

  create = "${local.peer_node}"

  ingress_vpc_name   = "${module.bootstrap.vpc_name}"
  ingress_vpc_id     = "${module.bootstrap.vpc_id}"
  ingress_region     = "${data.aws_region.default.name}"
  ingress_bastion_id = "${module.bootstrap.bastion_instance_id}"

  egress_vpc_name = "${local.peer_node 
    ? data.terraform_remote_state.peer-node[0].outputs.vpc_name : ""}"
  egress_vpc_id = "${local.peer_node 
    ? data.terraform_remote_state.peer-node[0].outputs.vpc_id : ""}"
  egress_region = "${local.peer_node 
    ? data.terraform_remote_state.peer-node[0].outputs.region : ""}"
  egress_bastion_id = "${local.peer_node 
    ? data.terraform_remote_state.peer-node[0].outputs.bastion_instance_id : ""}"
}
