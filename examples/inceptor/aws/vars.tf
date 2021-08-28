#
# MyCS Node IdKey
#
variable "mycs_node_private_key" {
  default = ""
}

variable "mycs_node_id_key" {
  default = ""
}

#
# SMTP settings for notifications
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

#
# Bastion Image
#

variable "bastion_use_fqdn" {
  type = string
}

variable "bastion_image_name" {
  type = string
}

variable "bastion_image_owner" {
  type = string
}

#
# Distinct CIDR for VPCs by region
#
variable "regional_vpc_cidr" {
  default = {
    # US West (N. California)
    us-west-1 = {
      vpc_cidr = "10.10.0.0/16"
    }
    # US West (Oregon)
    us-west-2  = {
      vpc_cidr = "10.11.0.0/16"
    }
    # US East (N. Virginia)
    us-east-1 = {
      vpc_cidr = "10.12.0.0/16"
    }
    # US East (Ohio)
    us-east-2 = {
      vpc_cidr = "10.13.0.0/16"
    }
    # Canada (Central)
    ca-central-1 = {
      vpc_cidr = "10.14.0.0/16"
    }
    # South America (Sao Paulo)
    sa-east-1 = {
      vpc_cidr = "10.15.0.0/16"
    }
    # EU (Ireland)
    eu-west-1 = {
      vpc_cidr = "10.16.0.0/16"
    }
    # EU (London)
    eu-west-2 = {
      vpc_cidr = "10.17.0.0/16"
    }
    # EU (Paris)
    eu-west-3 = {
      vpc_cidr = "10.18.0.0/16"
    }
    # EU (Frankfurt)
    eu-central-1 = {
      vpc_cidr = "10.19.0.0/16"
    }
    # EU (Stockholm)
    eu-north-1 = {
      vpc_cidr = "10.20.0.0/16"
    }
    # Asia Pacific (Mumbai)
    ap-south-1 = {
      vpc_cidr = "10.21.0.0/16"
    }
    # Asia Pacific (Tokyo)
    ap-northeast-1 = {
      vpc_cidr = "10.22.0.0/16"
    }
    # Asia Pacific (Seoul)
    ap-northeast-2 = {
      vpc_cidr = "10.23.0.0/16"
    }
    # Asia Pacific (Singapore)
    ap-southeast-1 = {
      vpc_cidr = "10.24.0.0/16"
    }
    # Asia Pacific (Sydney)
    ap-southeast-2 = {
      vpc_cidr = "10.25.0.0/16"
    }
  }
}
