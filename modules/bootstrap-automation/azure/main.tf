#
# The VPC Bootstrap resource group
#
resource "azurerm_resource_group" "bootstrap" {
  name     = "${var.vpc_name}-${var.region}"
  location = "${var.region}"
}

#
# Default SSH Key Pair
#

resource "tls_private_key" "default-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "default-ssh-key" {
  count = "${length(var.ssh_key_file_path) == 0 ? 0 : 1}"
  
  content  = "${tls_private_key.default-ssh-key.private_key_pem}"
  filename = "${var.ssh_key_file_path}/default-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.ssh_key_file_path}/default-ssh-key.pem"
  }
}
