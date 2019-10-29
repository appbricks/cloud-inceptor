#
# Flags whether the peering of the VPC with the 
# bastion node through which internet traffic 
# should egress should be created.
#
variable "create" {
  default = false
}

#
# Ingress VPC and Region
#
variable "ingress_vpc_name" {
  type = string
}
variable "ingress_vpc_id" {
  type = string
}
variable "ingress_region" {
  type = string
}
variable "ingress_bastion_id" {
  type = string
}

#
# Egress VPC and Region
#
variable "egress_vpc_name" {
  type = string
}
variable "egress_vpc_id" {
  type = string
}
variable "egress_region" {
  type = string
}
variable "egress_bastion_id" {
  type = string
}
