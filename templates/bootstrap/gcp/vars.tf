#
# Google compute region
#
variable "region" {
  type = "string"
}

#
# Used for certificates creations
#
variable "company_name" {
  type = "string"
}

variable "organization_name" {
  type = "string"
}

variable "locality" {
  type = "string"
}

variable "province" {
  type = "string"
}

variable "country" {
  type = "string"
}

#
# VPC and network variables
#
variable "vpc_name" {
  type = "string"
}

# VPC DNS zone
variable "dns_managed_zone_name" {
  type = "string"
}

variable "vpc_dns_zone" {
  type = "string"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_subnet_bits" {
  default = 8
}

variable "subnet_start" {
  default = 200
}

variable "max_azs" {
  default = 1
}

#
# Open VPN configuration
#
variable "vpn_server_port" {
  default = "2295"
}

variable "vpn_protocol" {
  default = "udp"
}

variable "vpn_network" {
  default = "192.168.111.0/24"
}

variable "vpn_network_dns" {
  default = ""
}

variable "vpn_tunnel_all_traffic" {
  default = "no"
}

variable "vpn_users" {
  default = ""
}

#
# Concourse bootstrap pipeline
#
variable "bootstrap_pipeline_file" {
  default = ""
}

variable "bootstrap_var_file" {
  default = ""
}
