#
# AWS Connection
#
provider "aws" {}

#
# Backend state
#
terraform {
  backend "s3" {
    bucket = "appbricks-use1-tf-states"
    key    = "test/cloud-inceptor"
  }
}

#
# Default Security Group allowing access from bastion 
# and to other instances with same security group.
#

resource "aws_security_group" "internal" {
  name        = "${var.vpc_name}: internal"
  description = "Rules for ingress and egress of network traffic within VPC."
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"
    self      = true
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.bastion_private_ip}/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["${module.vpc.bastion_private_ip}/32"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${module.vpc.bastion_private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#
# Default SSH Key Pair
#

resource "tls_private_key" "default-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "default-ssh-key" {
  content  = "${tls_private_key.default-ssh-key.private_key_pem}"
  filename = "default-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 default-ssh-key.pem"
  }
}

resource "aws_key_pair" "default" {
  key_name   = "${var.vpc_name}"
  public_key = "${tls_private_key.default-ssh-key.public_key_openssh}"
}
