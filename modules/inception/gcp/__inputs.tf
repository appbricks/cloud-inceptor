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

variable "vpc_cidr" {
  type = "string"
}

variable "dmz_network" {
  type = "string"
}

variable "dmz_subnetwork" {
  type = "string"
}

variable "dmz_subnetwork_cidr" {
  type = "string"
}

variable "admin_network" {
  type = "string"
}

variable "admin_subnetwork" {
  type = "string"
}

variable "admin_subnetwork_cidr" {
  type = "string"
}

variable "admin_subnetwork_gateway" {
  type = "string"
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
# Bastion access configuration
#
variable "bastion_admin_ssh_port" {
  default = "22"
}

variable "bastion_admin_user" {
  default = "bastion_admin"
}

variable "bastion_allow_public_ssh" {
  default = "false"
}

#
# Open VPN configuration
#
variable "vpn_server_port" {
  default = ""
}

variable "vpn_protocol" {
  default = ""
}

variable "vpn_network" {
  default = ""
}

variable "vpn_network_dns" {
  default = ""
}

variable "vpn_tunnel_all_traffic" {
  default = ""
}

variable "vpn_users" {
  default = ""
}

#
# Squid Proxy port
#
variable "squidproxy_server_port" {
  default = ""
}

#
# Concourse configuration
#
variable "concourse_server_port" {
  default = ""
}

variable "concourse_admin_password" {
  default = ""
}

variable "bootstrap_pipeline_file" {
  default = ""
}

variable "bootstrap_pipeline_vars" {
  default = ""
}
