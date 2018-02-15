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

  user_data_base64 = "${data.template_cloudinit_config.inceptor-cloudinit.rendered}"
}

data "template_cloudinit_config" "inceptor-cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    content = <<USER_DATA
#cloud-config

write_files:
- encoding: b64
  content: ${base64encode(data.template_file.inceptor-config.rendered)}
  path: /root/config.yml
  permissions: '0744'

# Web Server SSL certificates
- encoding: b64
  content: ${base64encode(tls_self_signed_cert.root-ca.cert_pem)}
  path: /etc/ssl/certs/bastion_web_ca.pem
  permissions: '0644'
- encoding: b64
  content: ${base64encode(tls_locally_signed_cert.bastion-web.cert_pem)}
  path: /etc/ssl/certs/bastion_web_cert.pem
  permissions: '0644'
- encoding: b64
  content: ${base64encode(tls_private_key.bastion-web.private_key_pem)}
  path: /etc/ssl/private/bastion_web_key.pem
  permissions: '0644'

# Web Server home page
- encoding: b64
  content: ${base64encode(data.template_file.www-static-index.rendered)}
  path: /var/www/html/index.html
  permissions: '0644'

USER_DATA
  }
}

data "template_file" "inceptor-config" {
  template = <<CONFIG
---
server:
  host: ${aws_eip.inception.public_ip}
  fqdn: ${length(var.bastion_host_name) == 0 ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}
  use_fqdn: ${var.bastion_use_fqdn}
  private_ip: ${aws_network_interface.inception-public.private_ips[0]}
  lan_interfaces: 'eth0|${aws_network_interface.inception-public.private_ips[0]}|${cidrnetmask(aws_subnet.dmz.0.cidr_block)}|${aws_subnet.dmz.0.cidr_block}|||,eth1|${aws_network_interface.inception-private.private_ips[0]}|${cidrnetmask(aws_subnet.engineering.0.cidr_block)}|${var.vpc_cidr}|${cidrnetmask(var.vpc_cidr)}||'

openvpn:
  port: ${var.vpn_server_port}
  protocol: ${var.vpn_protocol}
  subnet: ${var.vpn_network}
  netmask: ${cidrnetmask(var.vpn_network) }
  admin_passwd: ${random_string.vpn-admin-password.result}
  dns_servers: ${length(var.vpn_network_dns) == 0 ? cidrhost(var.vpc_cidr, 2): var.vpn_network_dns}
  server_domain: ${var.vpc_dns_zone}
  server_description: ${var.vpc_name}-vpn
  tunnel_all_traffic: ${var.vpn_tunnel_all_traffic}
  vpn_cert:
    name: ${var.vpc_name}_VPN
    org: ${var.organization_name}
    email: admin@${var.vpc_dns_zone}
    city: ${var.locality}
    province: ${var.province}
    country: ${var.country}
    ou: ${var.vpc_name}
    cn: ${var.vpc_dns_zone}
  users: '${var.vpn_users}'

concourse:
  port: 127.0.0.1:8080
  password: ${var.concourse_admin_password}
CONFIG
}

data "template_file" "www-static-index" {
  template = "${file("${path.module}/www-static-home/index.html")}"

  vars {
    environment = "${var.vpc_name}"
  }
}

resource "random_string" "vpn-admin-password" {
  length  = 16
  special = true
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
  private_ips     = ["${cidrhost(aws_subnet.dmz.0.cidr_block, -2)}"]
  security_groups = ["${aws_security_group.inception-public.id}"]

  tags {
    Name = "${var.vpc_name}: inception-public"
  }
}

resource "aws_network_interface" "inception-private" {
  subnet_id       = "${aws_subnet.engineering.0.id}"
  private_ips     = ["${cidrhost(aws_subnet.engineering.0.cidr_block, -2)}"]
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

resource "aws_security_group" "inception-private" {
  name        = "${var.vpc_name}: inception rules private"
  description = "Rules for ingress and egress of network traffic to inception instance."
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

output "vpn-admin-password" {
  value = "${random_string.vpn-admin-password.result}"
}

output "bastion-private-ip" {
  value = "${aws_instance.inception.private_ip}"
}

output "bastion-public-ip" {
  value = "${aws_instance.inception.public_ip}"
}
