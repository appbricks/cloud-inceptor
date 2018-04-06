#
# Google Cloud Region
#
variable "region" {
  type = "string"
}

#
# Certificate Subject data for certificate creation
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
# Root CA key and cert to use for signing self signed certificates
#

variable "root_ca_key" {
  default = ""
}

variable "root_ca_cert" {
  default = ""
}

#
# VPC and network variables
#
variable "vpc_name" {
  type = "string"
}

variable "vpc_dns_zone" {
  type = "string"
}

variable "max_azs" {
  type = "string"
}

#
# Networks
#
variable "vpc_cidr" {
  type = "string"
}

variable "vpc_subnet_bits" {
  type = "string"
}

variable "vpc_subnet_start" {
  type = "string"
}

variable "dmz_cidr" {
  default = ""
}

#
# Local file path to write SSH private key for bastion instance
#
variable "ssh_key_file_path" {
  type = "string"
}

#
# Bastion inception instance variables
#
variable "bastion_instance_type" {
  default = "n1-standard-1"
}

variable "bastion_image_name" {
  default = "appbricks-inceptor-bastion"
}

variable "bastion_root_disk_size" {
  default = 30
}

variable "bastion_concourse_vols_disk_size" {
  default = 10
}

variable "bastion_host_name" {
  default = ""
}

variable "bastion_use_fqdn" {
  default = "true"
}

#
# Squid Proxy configuration
#
variable "squidproxy_server_port" {
  default = "8888"
}

#
# Open VPN configuration
#
variable "vpn_server_port" {
  type = "string"
}

variable "vpn_protocol" {
  type = "string"
}

variable "vpn_network" {
  type = "string"
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
# Concourse configuration
#
variable "concourse_server_port" {
  default = "string"
}

variable "concourse_admin_password" {
  default = "string"
}

variable "bootstrap_pipeline_file" {
  default = ""
}

variable "bootstrap_pipeline_vars" {
  type = ""
}
