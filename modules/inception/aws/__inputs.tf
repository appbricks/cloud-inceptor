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
variable "vpc_id" {
  type = "string"
}

variable "vpc_name" {
  type = "string"
}

variable "vpc_dns_zone" {
  type = "string"
}

variable "vpc_cidr" {
  type = "string"
}

variable "dmz_subnet_ids" {
  type = "list"
}

variable "dmz_subnet_cidrs" {
  type = "list"
}

variable "admin_subnet_ids" {
  type = "list"
}

variable "admin_subnet_cidrs" {
  type = "list"
}

#
# Local file path to write SSH private key for bastion instance
#
variable "ssh_key_file_path" {
  default = "bastion-admin-ssh-key.pem"
}

#
# Bastion inception instance variables
#
variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "bastion_image_name" {
  default = "appbricks-inceptor-bastion"
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
  type = "string"
}

variable "vpn_tunnel_all_traffic" {
  type = "string"
}

variable "vpn_users" {
  type = "string"
}

#
# Concourse configuration
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
