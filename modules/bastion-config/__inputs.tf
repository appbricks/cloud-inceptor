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
# VPC and network variables
#
variable "vpc_name" {
  type = "string"
}

variable "vpc_dns_zone" {
  type = "string"
}

variable "dmz_network" {
  type = "string"
}

variable "dmz_subnetwork" {
  type = "string"
}

variable "mgmt_network" {
  type = "string"
}

variable "mgmt_subnetwork" {
  type = "string"
}

#
# Local file path to write SSH private key for bastion instance
#
variable "ssh_key_file_path" {
  type = "string"
}

#
# Bastion inception instance network configuration
#
variable "bastion_fqdn" {
  type = "string"
}

variable "bastion_use_fqdn" {
  type = "string"
}

variable "bastion_public_ip" {
  type = "string"
}

#
# Bastion NIC 1 on DMZ network
#
variable "bastion_nic1_private_ip" {
  default = ""
}

variable "bastion_nic1_netmask" {
  default = ""
}

variable "bastion_nic1_lan_cidr" {
  default = ""
}

variable "bastion_nic1_lan_netmask" {
  default = ""
}

variable "bastion_nic1_lan_gateway" {
  default = ""
}

#
# Bastion NIC 2 on internal network
#
variable "bastion_nic2_private_ip" {
  default = ""
}

variable "bastion_nic2_netmask" {
  default = ""
}

variable "bastion_nic2_lan_cidr" {
  default = ""
}

variable "bastion_nic2_lan_netmask" {
  default = ""
}

variable "bastion_nic2_lan_gateway" {
  default = ""
}

#
# Bastion persistent volumes
#

variable "data_volume_name" {
  default = ""
}

#
# Bastion inception instance Squid Proxy configuration
#
variable "squidproxy_server_port" {
  type = "string"
}

#
# Bastion inception instance Open VPN configuration
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
  type = "string"
}

variable "vpn_tunnel_all_traffic" {
  type = "string"
}

variable "vpn_users" {
  type = "string"
}

#
# Bastion inception instance Concourse configuration
#
variable "concourse_server_port" {
  type = "string"
}

variable "concourse_admin_password" {
  type = "string"
}

variable "bootstrap_pipeline_file" {
  type = "string"
}

variable "bootstrap_pipeline_vars" {
  type = "string"
}
