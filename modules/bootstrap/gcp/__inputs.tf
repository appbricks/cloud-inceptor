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

variable "vpc_subnet_start" {
  default = 200
}

variable "dmz_cidr" {
  default = ""
}

variable "max_azs" {
  default = 1
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
  default = 50
}

variable "bastion_concourse_vols_disk_size" {
  default = 250
}

variable "bastion_host_name" {
  default = ""
}

variable "bastion_concourse_data_disk_size" {
  default = 250
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
# Concourse
#
variable "concourse_server_port" {
  default = "8080"
}

variable "concourse_admin_password" {
  default = "Passw0rd"
}

# Concourse bootstrap pipeline
variable "bootstrap_pipeline_file" {
  default = ""
}

variable "bootstrap_pipeline_vars" {
  default = ""
}

#
# Jumpbox
#

variable "deploy_jumpbox" {
  default = "true"
}

variable "jumpbox_data_disk_size" {
  default = "160"
}
