#
# Azure region
#
variable "region" {
  type = string
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

variable "bastion_use_managed_image" {
  type = bool
}

variable "bastion_image_name" {
  type = string
}

variable "bastion_image_storage_account_prefix" {
  default = "abi"
}

#
# Distinct CIDR for VPCs by region
#
variable "regional_vpc_cidr" {
  default = {
    westus = {
      vpc_cidr = "10.10.0.0/16"
    }
    westus2 = {
      vpc_cidr = "10.11.0.0/16"
    }
    westcentralus = {
      vpc_cidr = "10.12.0.0/16"
    }
    northcentralus = {
      vpc_cidr = "10.13.0.0/16"
    }
    centralus = {
      vpc_cidr = "10.14.0.0/16"
    }
    southcentralus = {
      vpc_cidr = "10.15.0.0/16"
    }
    eastus = {
      vpc_cidr = "10.16.0.0/16"
    }
    eastus2 = {
      vpc_cidr = "10.17.0.0/16"
    }
    canadacentral = {
      vpc_cidr = "10.18.0.0/16"
    }
    canadaeast = {
      vpc_cidr = "10.19.0.0/16"
    }
    brazilsouth = {
      vpc_cidr = "10.20.0.0/16"
    }
    ukwest = {
      vpc_cidr = "10.21.0.0/16"
    }
    uksouth = {
      vpc_cidr = "10.22.0.0/16"
    }
    francecentral = {
      vpc_cidr = "10.23.0.0/16"
    }
    francesouth = {
      vpc_cidr = "10.24.0.0/16"
    }
    westeurope = {
      vpc_cidr = "10.25.0.0/16"
    }
    northeurope = {
      vpc_cidr = "10.26.0.0/16"
    }
    norwaywest = {
      vpc_cidr = "10.27.0.0/16"
    }
    norwayeast = {
      vpc_cidr = "10.28.0.0/16"
    }
    switzerlandwest = {
      vpc_cidr = "10.29.0.0/16"
    }
    switzerlandnorth = {
      vpc_cidr = "10.30.0.0/16"
    }
    germanywestcentral = {
      vpc_cidr = "10.31.0.0/16"
    }
    germanynorth = {
      vpc_cidr = "10.32.0.0/16"
    }
    southafricawest = {
      vpc_cidr = "10.33.0.0/16"
    }
    southafricanorth = {
      vpc_cidr = "10.34.0.0/16"
    }
    uaecentral = {
      vpc_cidr = "10.35.0.0/16"
    }
    uaenorth = {
      vpc_cidr = "10.36.0.0/16"
    }
    westindia = {
      vpc_cidr = "10.37.0.0/16"
    }
    centralindia = {
      vpc_cidr = "10.38.0.0/16"
    }
    southindia = {
      vpc_cidr = "10.39.0.0/16"
    }
    eastasia = {
      vpc_cidr = "10.40.0.0/16"
    }
    southeastasia = {
      vpc_cidr = "10.41.0.0/16"
    }
    koreacentral = {
      vpc_cidr = "10.42.0.0/16"
    }
    koreasouth = {
      vpc_cidr = "10.43.0.0/16"
    }
    japanwest = {
      vpc_cidr = "10.44.0.0/16"
    }
    japaneast = {
      vpc_cidr = "10.45.0.0/16"
    }
    australiacentral = {
      vpc_cidr = "10.46.0.0/16"
    }
    australiacentral2 = {
      vpc_cidr = "10.47.0.0/16"
    }
    australiaeast = {
      vpc_cidr = "10.48.0.0/16"
    }
    australiasoutheast = {
      vpc_cidr = "10.49.0.0/16"
    }
  }
}
