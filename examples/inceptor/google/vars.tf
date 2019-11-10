#
# Google Cloud Platform region
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

#
# Distinct CIDR for VPCs by region
#
variable "regional_vpc_cidr" {
  default = {
    # The Dalles, Oregon, USA
    us-west1 = {
      vpc_cidr = "10.10.0.0/16"
    }
    # Los Angeles, California, USA
    us-west2 = {
      vpc_cidr = "10.11.0.0/16"
    }
    # Council Bluffs, Iowa, USA
    us-central1 = {
      vpc_cidr = "10.12.0.0/16"
    }
    # Ashburn, Northern Virginia, USA
    us-east4 = {
      vpc_cidr = "10.13.0.0/16"
    }
    # Moncks Corner, South Carolina, USA
    us-east1 = {
      vpc_cidr = "10.14.0.0/16"
    }
    # Montréal, Québec, Canada
    northamerica-northeast1 = {
      vpc_cidr = "10.15.0.0/16"
    }
    # Osasco (São Paulo), Brazil
    southamerica-east1 = {
      vpc_cidr = "10.16.0.0/16"
    }
    # St. Ghislain, Belgium
    europe-west1 = {
      vpc_cidr = "10.17.0.0/16"
    }
    # London, England, UK
    europe-west2 = {
      vpc_cidr = "10.18.0.0/16"
    }
    # Frankfurt, Germany
    europe-west3 = {
      vpc_cidr = "10.19.0.0/16"
    }
    # Eemshaven, Netherlands
    europe-west4 = {
      vpc_cidr = "10.20.0.0/16"
    }
    # Zürich, Switzerland
    europe-west6 = {
      vpc_cidr = "10.21.0.0/16"
    }
    # Hamina, Finland
    europe-north1 = {
      vpc_cidr = "10.22.0.0/16"
    }
    # Mumbai, India
    asia-south1 = {
      vpc_cidr = "10.23.0.0/16"
    }
    # Changhua County, Taiwan
    asia-east1 = {
      vpc_cidr = "10.24.0.0/16"
    }
    # Hong Kong
    asia-east2 = {
      vpc_cidr = "10.25.0.0/16"
    }
    # Tokyo, Japan
    asia-northeast1 = {
      vpc_cidr = "10.26.0.0/16"
    }
    # Osaka, Japan
    asia-northeast2 = {
      vpc_cidr = "10.27.0.0/16"
    }
    # Jurong West, Singapore
    asia-southeast1 = {
      vpc_cidr = "10.28.0.0/16"
    }
    # Sydney, Australia
    australia-southeast1 = {
      vpc_cidr = "10.29.0.0/16"
    }
  }
}
