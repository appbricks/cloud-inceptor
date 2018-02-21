#
# Inception Bastion VM
#

resource "aws_instance" "bastion" {
  instance_type = "${var.bastion_instance_type}"
  ami           = "${data.aws_ami.bastion.id}"
  key_name      = "${aws_key_pair.bastion.key_name}"

  tags {
    Name = "${var.vpc_name}: bastion"
  }

  root_block_device {
    volume_size = "160"
  }

  network_interface {
    network_interface_id = "${aws_network_interface.bastion-public.id}"
    device_index         = 0
  }

  network_interface {
    network_interface_id = "${aws_network_interface.bastion-private.id}"
    device_index         = 1
  }

  user_data_base64 = "${module.common.bastion_cloud_init_config}"
}

#
# AMI
#

data "aws_ami" "bastion" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.bastion_image_name}"]
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

resource "aws_network_interface" "bastion-public" {
  subnet_id       = "${aws_subnet.dmz.0.id}"
  private_ips     = ["${cidrhost(aws_subnet.dmz.0.cidr_block, -2)}"]
  security_groups = ["${aws_security_group.bastion-public.id}"]

  tags {
    Name = "${var.vpc_name}: bastion-public"
  }
}

resource "aws_network_interface" "bastion-private" {
  subnet_id       = "${aws_subnet.engineering.0.id}"
  private_ips     = ["${cidrhost(aws_subnet.engineering.0.cidr_block, -2)}"]
  security_groups = ["${aws_security_group.bastion-private.id}"]

  tags {
    Name = "${var.vpc_name}: bastion-private"
  }
}

resource "aws_eip_association" "bastion" {
  network_interface_id = "${aws_network_interface.bastion-public.id}"
  allocation_id        = "${aws_eip.bastion.id}"
}

resource "aws_eip" "bastion" {
  vpc = true
}

#
# Security 
#

resource "aws_security_group" "bastion-public" {
  name        = "${var.vpc_name}: bastion rules public"
  description = "Rules for ingress and egress of network traffic to bastion instance."
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = "80"
    to_port     = "80"
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
    protocol    = "${var.vpn_protocol}"
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

resource "aws_security_group" "bastion-private" {
  name        = "${var.vpc_name}: bastion rules private"
  description = "Rules for ingress and egress of network traffic to bastion instance."
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpn_network}"]
  }

  ingress {
    from_port   = "${var.squidproxy_server_port}"
    to_port     = "${var.squidproxy_server_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.vpn_network}", "${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
}

#
# SSH key pair
#

resource "aws_key_pair" "bastion" {
  key_name   = "bastion"
  public_key = "${module.common.bastion_openssh_public_key}"
}

#
# Outputs
#

output "bastion_private_ip" {
  value = "${aws_network_interface.bastion-private.private_ips[0]}"
}

output "bastion_public_ip" {
  value = "${aws_eip.bastion.public_ip}"
}
