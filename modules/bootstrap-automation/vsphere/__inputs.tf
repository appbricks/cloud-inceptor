#
# VMW IaaS Configuration
#

variable "datacenter" {
  type = "string"
}

variable "ephemeral_datastore" {
  type = "string"
}

variable "persistent_datastore" {
  type = "string"
}

# Map of availability zones defined
# as cluster => resource pool pairs.
variable "availability_zones" {
  type = "map"
}

variable "dmz_network" {
  default = ""
}

variable "dmz_network_cidr" {
  default = ""
}

variable "dmz_network_gateway" {
  default = ""
}

variable "admin_network" {
  type = "string"
}

variable "admin_network_cidr" {
  type = "string"
}

variable "admin_network_gateway" {
  default = ""
}

#
# VPC details
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
  default = []
}

variable "vpc_internal_dns_records" {
  default = []
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
# Local file path to write SSH private key for bastion instance
#
variable "ssh_key_file_path" {
  type = "string"
}

#
# Bastion inception instance variables
#
variable "bastion_instance_memory" {
  default = "4096"
}

variable "bastion_instance_cpus" {
  default = "2"
}

variable "bastion_template_path" {
  default = "templates/appbricks-inceptor"
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

variable "bastion_public_ip" {
  default = ""
}

variable "bastion_dmz_ip" {
  default = ""
}

variable "bastion_admin_ip" {
  type = "string"
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

variable "jumpbox_instance_memory" {
  default = "1024"
}

variable "jumpbox_instance_cpus" {
  default = "1"
}

variable "jumpbox_data_disk_size" {
  default = "160"
}

variable "jumpbox_admin_ip" {
  default = ""
}

variable "jumpbox_template_path" {
  default = "templates/appbricks-ubuntu"
}
