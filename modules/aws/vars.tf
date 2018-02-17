#
# Required for certificates
#

variable "company_name" {}
variable "organization_name" {}
variable "locality" {}
variable "province" {}
variable "country" {}

#
# VPC and network variables
#

variable "vpc_name" {}

variable "vpc_dns_zone" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "max_azs" {
  default = 1
}

variable "subnet_start" {
  default = 200
}

#
# Bastion inception instance variables
#

variable "bastion_host_name" {
  default = ""
}

variable "bastion_use_fqdn" {
  default = "true"
}

variable "ssh_key_file_path" {
  default = "ssh-key.pem"
}

variable "squidproxy_server_port" {
  default = "8888"
}

#
# Concourse configurations
#

variable "concourse_server_port" {
  default = "8080"
}

variable "concourse_admin_password" {
  default = "Passw0rd"
}

variable "bootstrap_pipeline_file" {
  default = ""
}

variable "bootstrap_var_file" {
  default = ""
}

#
# VPN configuration variables
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
