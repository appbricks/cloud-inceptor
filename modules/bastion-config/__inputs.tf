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
  type = "string"
}

variable "root_ca_cert" {
  type = "string"
}

#
# VPC and network variables
#
variable "vpc_name" {
  type = "string"
}

variable "vpc_cidr" {
  type = "string"
}

variable "vpc_dns_zone" {
  type = "string"
}

variable "vpc_internal_dns_zones" {
  type = "list"
}

variable "vpc_internal_dns_records" {
  type = "list"
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
# DNS resolvers for the Bastion server
#
variable "bastion_dns" {
  type = "string"
}

#
# Bastion NIC 1 on DMZ network
#
variable "bastion_nic1_private_ip" {
  type = "string"
}

variable "bastion_nic1_netmask" {
  type = "string"
}

variable "bastion_nic1_lan_cidr" {
  type = "string"
}

variable "bastion_nic1_lan_netmask" {
  type = "string"
}

variable "bastion_nic1_lan_gateway" {
  type = "string"
}

#
# Bastion NIC 2 on internal network
#
variable "bastion_nic2_private_ip" {
  type = "string"
}

variable "bastion_nic2_netmask" {
  type = "string"
}

variable "bastion_nic2_lan_cidr" {
  type = "string"
}

variable "bastion_nic2_lan_netmask" {
  type = "string"
}

variable "bastion_nic2_lan_gateway" {
  type = "string"
}

#
# Bastion persistent volumes
#

variable "data_volume_name" {
  default = ""
}

#
# Bastion access configuration
#
variable "bastion_admin_ssh_port" {
  type = "string"
}

variable "bastion_admin_user" {
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

# Path to cloud inceptor repository provided as input 
# to concourse tasks. This is required to be able to 
# locate tasks such as notifications found in that
# repository.
variable "pipeline_automation_path" {
  type = "string"
}

# S3 bucket where automation related artifacts
# will be persisted.
variable "automation_data_bucket" {
  default = "auto"
}

# Email to send concourse job notifications to
variable "notification_email" {
  type = "string"
}

#
# Bastion inception instance SMTP configuration
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
# Bastion inception instance Squid Proxy configuration
#
variable "squidproxy_server_port" {
  type = "string"
}
