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

# List of local Networks to attach the bastion instance to.
# The "create" and "vlan" attributes are required only if
# if network does not and needs to be created as a 
# distributed virtual switch.
#
# For example:
#
# [ {
#   vsphere_network = ...
#   cidr            = ...
#   gateway         = ...
#   bastion_ip      = ...
#  
#   create  = "true"
#   vlan_id = 4092
# } ]
#
# If the bastion_ip is not provided then it will be calculatd
# based on var.bastion_nic_hostnum which would be the host
# number offset for the network's CIDR. If the gateway is not
# provided then the bastion will provide routing and NATing
# services via the bastion's ip on that network.
#
variable "local_networks" {
  type = "list"
}

#
# ESX hosts and NICs need to be provided only if one or more
# of the networks declared in the 
#
variable "esxi_hosts" {
  default = []
}

variable "esxi_host_vmnics" {
  default = []
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
  default = [""]
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

variable "bastion_nic_hostnum" {
  default = "2"
}

variable "allow_bastion_icmp" {
  default = false
}

#
# DNS resolvers for the  server
#
variable "bastion_dns" {
  default = ""
}

#
# Setup bastion as a DHCP server for LANs
#

variable "enable_bastion_as_dhcpd" {
  default = "false"
}

variable "dhcpd_lease_range" {
  default = "54"
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
variable "ovpn_server_port" {
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

variable "vpn_network" {
  default = "192.168.111.0/24"
}

variable "vpn_tunnel_all_traffic" {
  default = "no"
}

variable "vpn_idle_action" {
  default = "none"
}

variable "vpn_users" {
  default = []
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

variable "jumpbox_nic_hostnum" {
  default = "3"
}

variable "jumpbox_template_path" {
  default = "templates/appbricks-ubuntu"
}
