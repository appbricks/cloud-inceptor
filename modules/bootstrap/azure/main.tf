#
# The VPC Bootstrap resource group
#
resource "azurerm_resource_group" "bootstrap" {
  name     = "${var.vpc_name}-${var.region}"
  location = var.region
}

#
# Default SSH Key Pair
#

resource "tls_private_key" "default-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

