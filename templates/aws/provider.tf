#
# AWS Connection
#

provider "aws" {}

#
# Availability Zones in current region
#

data "aws_availability_zones" "available" {}
