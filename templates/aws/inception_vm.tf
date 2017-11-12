#
# External variables
#

variable "ssh_key_file_path" {
  default = "ssh-key.pem"
}

variable "vpn_server_port" {
  default = "1194"
}

variable "squidproxy_server_port" {
  default = "8888"
}

variable "concourse_server_port" {
  default = "8080"
}

#
# Inception VM
#

resource "aws_instance" "inception" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.inception.id}"
  key_name      = "${aws_key_pair.inception.key_name}"

  tags {
    Name = "${var.vpc_name}: inception"
  }

  network_interface {
    network_interface_id = "${aws_network_interface.inception-public.id}"
    device_index         = 0
  }

  network_interface {
    network_interface_id = "${aws_network_interface.inception-private.id}"
    device_index         = 1
  }

  user_data = <<USER_DATA
---
server:
  host: ${aws_eip.inception.public_ip}
  private_ip: ${aws_network_interface.inception-public.private_ips[0]}
  lan_interfaces: 'eth0|${aws_network_interface.inception-public.private_ips[0]}|${cidrnetmask(aws_subnet.dmz.0.cidr_block)}|${aws_subnet.dmz.0.cidr_block}|||,eth1|${aws_network_interface.inception-private.private_ips[0]}|${cidrnetmask(aws_subnet.engineering.0.cidr_block)}|${var.vpc_cidr}|${cidrnetmask(var.vpc_cidr)}||'

concourse:
  port: 127.0.0.1:8080
  password: Passw0rd

USER_DATA
}

#
# AMI
#

data "aws_ami" "inception" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Inception VM for Automated Deployments"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

#
# Networking
#

resource "aws_network_interface" "inception-public" {
  subnet_id       = "${aws_subnet.dmz.0.id}"
  private_ips     = ["${cidrhost(aws_subnet.dmz.0.cidr_block, 254)}"]
  security_groups = ["${aws_security_group.inception-public.id}"]

  tags {
    Name = "${var.vpc_name}: inception-public"
  }
}

resource "aws_network_interface" "inception-private" {
  subnet_id       = "${aws_subnet.engineering.0.id}"
  private_ips     = ["${cidrhost(aws_subnet.engineering.0.cidr_block, 254)}"]
  security_groups = ["${aws_security_group.inception-private.id}"]

  tags {
    Name = "${var.vpc_name}: inception-private"
  }
}

resource "aws_eip_association" "inception" {
  network_interface_id = "${aws_network_interface.inception-public.id}"
  allocation_id        = "${aws_eip.inception.id}"
}

resource "aws_eip" "inception" {
  vpc = true
}

#
# Security group 
#

resource "aws_security_group" "inception-public" {
  name        = "${var.vpc_name}: inception rules public"
  description = "Rules for ingress and egress of network traffic to inception instance."
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.vpn_server_port}"
    to_port     = "${var.vpn_server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group" "inception-private" {
  name        = "${var.vpc_name}: inception rules private"
  description = "Rules for ingress and egress of network traffic to inception instance."
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.squidproxy_server_port}"
    to_port     = "${var.squidproxy_server_port}"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.concourse_server_port}"
    to_port     = "${var.concourse_server_port}"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
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
# SSH Key
#

resource "tls_private_key" "inception-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "inception-ssh-key" {
  content  = "${tls_private_key.inception-ssh-key.private_key_pem}"
  filename = "${var.ssh_key_file_path}"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.ssh_key_file_path}"
  }
}

resource "aws_key_pair" "inception" {
  key_name   = "inception"
  public_key = "${tls_private_key.inception-ssh-key.public_key_openssh}"
}

#
# Outputs
#

output "inception-private-ip" {
  value = "${aws_instance.inception.private_ip}"
}

output "inception-public-ip" {
  value = "${aws_instance.inception.public_ip}"
}
