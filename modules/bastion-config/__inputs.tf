#
# Certificate Subject data for certificate creation
#
variable "company_name" {
  type = string
}

variable "organization_name" {
  type = string
}

variable "locality" {
  type = string
}

variable "province" {
  type = string
}

variable "country" {
  type = string
}

#
# Root CA key and cert to use for signing self signed certificates
#
variable "root_ca_key" {
  type = string
}

variable "root_ca_cert" {
  type = string
}

#
# VPC and network variables
#
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_dns_zone" {
  type = string
}

variable "vpc_internal_dns_zones" {
  type = list
}

variable "vpc_internal_dns_records" {
  type = list
}

#
# Bastion inception instance network configuration
#
variable "bastion_fqdn" {
  type = string
}

variable "bastion_use_fqdn" {
  type = bool
}

variable "bastion_public_ip" {
  type = string
}

#
# Certify bastion host using letsencrypt certificates
#
variable "certify_bastion" {
  default = false
}

#
# DNS resolvers for the Bastion server
#
variable "bastion_dns" {
  type = string
}

#
# Setup bastion as a DHCP server for LANs
#

variable "enable_bastion_as_dhcpd" {
  default = false
}

variable "dhcpd_lease_range" {
  default = "50"
}

# The local IP of the external or NAT interface
variable "bastion_dmz_itf_ip" {
  type = string
}

# The local IP of the interface attached to the 
# admin network 
variable "bastion_admin_itf_ip" {
  type = string
}

# Bastion NIC configurations
#
# This should be a list attributes of all the 
# NICs to be configured on the Bastion. The 
# list should be a list of:
#
# - private_ip
# - netmask
# - cidr
# - gateway
#
# The first network is assumed to be the DMZ
# network with the ability to NAT to the public
# domain. The second network if present is
# assumed to be the administration network.
variable "bastion_nic_config" {
  type = list
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
  type = string
}

variable "bastion_admin_user" {
  type = string
}

#
# Bastion inception instance Open VPN configuration
#
variable "vpn_type" {
  # one of "openvpn" or "ipsec"
  default = ""
}

variable "vpn_network" {
  type = string
}

variable "vpn_tunnel_all_traffic" {
  type = string
}

variable "vpn_idle_action" {
  type = string
}

variable "vpn_users" {
  type = string
}

#
# OpenVPN configuration
#
variable "ovpn_server_port" {
  type = string
}

variable "ovpn_protocol" {
  type = string
}

#
# Wireguard configuration
#
variable "wireguard_port" {
  type = string
}

variable "wireguard_subnet_ip" {
  type = string
}

#
# Enable tunnelling of VPN within another tunnel 
# when firewalls and telco's block OpenVPN via
# deep-packet-inspection.
#
variable "tunnel_vpn_port_start" {
  default = ""
}

variable "tunnel_vpn_port_end" {
  default = ""
}

#
# Bastion inception instance Concourse configuration
#
variable "concourse_server_port" {
  type = string
}

variable "concourse_admin_password" {
  type = string
}

variable "bootstrap_pipeline_file" {
  type = string
}

variable "bootstrap_pipeline_vars" {
  type = string
}

# Path to cloud inceptor repository provided as input 
# to concourse tasks. This is required to be able to 
# locate tasks such as notifications found in that
# repository.
variable "pipeline_automation_path" {
  type = string
}

# Email to send concourse job notifications to
variable "notification_email" {
  type = string
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
  type = string
}

#
# Compress cloud-init data
#
variable "compress_cloudinit" {
  default = true
}
