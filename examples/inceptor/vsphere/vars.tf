#
# VSphere Environment
#

variable "datacenter" {
  type = "string"
}

variable "availability_zones" {
  default = {
    az1 = {
      cluster = "cluster"
    }
  }
}

variable "ephemeral_datastore" {
  type = "string"
}

variable "persistent_datastore" {
  type = "string"
}

variable "vpc_cidr" {
  type = "string"
}

variable "local_networks" {
  type = "list"
}

variable "esxi_hosts" {
  default = []
}

variable "esxi_host_vmnics" {
  default = []
}

variable "deploy_test_instances" {
  default = false
}

#
# Notifications
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

variable "notification_email" {
  default = ""
}
