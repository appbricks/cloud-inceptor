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
# VPC
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

variable "max_azs" {
  default = 1
}

#
# Networks
#
variable "vpc_cidr" {
  type = "string"
}

# Subnet segments will be calculated based 
# on the number of AZs, however only 'max_azs' 
# segments will be assigned per network.
variable "subnet_bits" {
  type = "string"
}

variable "subnet_start" {
  default = 200
}

#
# Local file path to write SSH private key for bastion instance
#
variable "ssh_key_file_path" {
  default = "vpn-admin-ssh-key.pem"
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

variable "bootstrap_var_file" {
  default = ""
}
