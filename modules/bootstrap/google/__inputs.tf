#
# Google compute region
#
variable "region" {
  type = string
}

variable "time_zone" {
  default = "Etc/UTC"
}

#
# MyCloudSpace node service keys
#
variable "mycs_node_private_key" {
  default = ""
}

variable "mycs_node_id_key" {
  default = ""
}

variable "mycs_node_id" {
  default = ""
}

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
  default = ""
}

variable "root_ca_cert" {
  default = ""
}

#
# VPC and network variables
#
variable "vpc_name" {
  type = string
}

variable "vpc_dns_zone" {
  type = string
}

# External DNS zone
variable "dns_managed_zone_name" {
  default = ""
}

# Attach DNS to parent zone. This 
# requires the parent zone to exist 
# within the same cloud provider.
# Otherwise once deployed the VPC
# zone's nameservers need to be added
# manually to the parent zone.
variable "attach_dns_zone" {
  default = false
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "vpc_subnet_bits" {
  default = 4
}

variable "vpc_subnet_start" {
  default = 1
}

variable "vpc_internal_dns_zones" {
  default = [""]
}

variable "vpc_internal_dns_records" {
  default = []
}

variable "dmz_cidr" {
  default = ""
}

variable "admin_cidr" {
  default = ""
}

variable "max_azs" {
  default = 1
}

# Internal CIDR for all VPC address 
# spaces across all regions
variable "global_internal_cidr" {
  default = ""
}

#
# Bastion inception instance variables
#
variable "bastion_instance_type" {
  default = "n1-standard-1"
}

variable "bastion_use_project_image" {
  default = true
}

variable "bastion_image_name" {
  default = "appbricks-bastion_dev"
}

variable "bastion_image_bucket_prefix" {
  default = "mycsimages"
}

variable "bastion_root_disk_size" {
  default = 10
}

variable "bastion_data_disk_size" {
  default = 5
}

variable "bastion_host_name" {
  default = ""
}

variable "bastion_use_fqdn" {
  default = true
}

variable "allow_bastion_icmp" {
  default = false
}

#
# Configure admin network segment.
#
variable "configure_admin_network" {
  default = false
}

#
# Certify bastion host using letsencrypt certificates
#
variable "certify_bastion" {
  default = false
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
variable "bastion_admin_api_port" {
  default = "443"
}

variable "bastion_admin_ssh_port" {
  default = "22"
}

variable "bastion_admin_user" {
  default = "bastion-admin"
}

variable "bastion_allow_public_ssh" {
  default = true
}

#
# VPN configuration
#
variable "vpn_type" {
  # one of "wireguard", "openvpn" or "ipsec"
  default = ""
}

variable "vpn_network" {
  default = "192.168.111.0/24"
}

variable "vpn_protected_sub_range" {
  default = 2
}

variable "vpn_tunnel_all_traffic" {
  default = "no"
}

variable "vpn_idle_action" {
  default = "none"
}

variable "vpn_idle_shutdown_time" {
  default = 10
}

variable "vpn_users" {
  default = []
}

#
# Wireguard configuration
#
variable "wireguard_service_port" {
  default = ""
}

variable "wireguard_mesh_network" {
  default = "192.168.112.0/24"
}

variable "wireguard_mesh_node" {
  default = 1
}

#
# UDP port of mycs-node DERP STUN service
#
variable "derp_stun_port" {
  default = ""
}

#
# OpenVPN configuration
#
variable "ovpn_service_port" {
  default = ""
}

variable "ovpn_protocol" {
  default = "udp"
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
  default = true
}

variable "jumpbox_data_disk_size" {
  default = "160"
}
