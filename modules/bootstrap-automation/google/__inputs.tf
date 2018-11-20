#
# Google compute region
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

variable "vpc_internal_dns_zones" {
  type = "list"
}

variable "vpc_internal_dns_records" {
  default = []
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

variable "bastion_data_disk_size" {
  default = 250
}

variable "bastion_host_name" {
  default = ""
}

variable "bastion_use_fqdn" {
  default = "true"
}

#
# DNS resolvers for the  server
#
variable "bastion_dns" {
  default = ""
}

#
# Bastion access configuration
#
variable "bastion_admin_ssh_port" {
  default = "22"
}

variable "bastion_admin_user" {
  default = "bastion-admin"
}

variable "bastion_allow_public_ssh" {
  default = "true"
}

#
# Open VPN configuration
#
variable "vpn_server_port" {
  default = ""
}

variable "vpn_protocol" {
  default = "udp"
}

variable "vpn_network" {
  default = "192.168.111.0/24"
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
  default = ""
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

# Path to cloud inceptor repository provided as input 
# to concourse tasks. This is required to be able to 
# locate tasks such as notifications found in that
# repository. This path should be from the build 
# root of the concourse build container and the
# first element would typically be the name of
# the concourse automation repository resource path.
variable "pipeline_automation_path" {
  default = "automation"
}

# Email to send concourse job notifications to
variable "notification_email" {
  default = ""
}

#
# Configure SMTP
#
variable "smtp_relay_host" {
  default = ""
}

variable "smtp_relay_port" {
  default = ""
}

variable "smtp_relay_api_key" {
  default = ""
}

#
# Squid Proxy port
#
variable "squidproxy_server_port" {
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
