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

  network_interface {
    network_interface_id = "${aws_network_interface.bastion-public.id}"
    device_index         = 0
  }

  network_interface {
    network_interface_id = "${aws_network_interface.bastion-private.id}"
    device_index         = 1
  }

  user_data_base64 = "${data.template_cloudinit_config.bastion-cloudinit.rendered}"
}

#
# Bastion configuration templates
#

data "template_cloudinit_config" "bastion-cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    content = <<USER_DATA
#cloud-config

write_files:
- encoding: b64
  content: ${base64encode(data.template_file.bastion-config.rendered)}
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

# Bootstrap Pipeline
- encoding: b64
  content: ${base64encode(file(length(var.bootstrap_pipeline_file) == 0 ? "${path.module}/_placeholder_" : var.bootstrap_pipeline_file))}
  path: /root/bootstrap.yml
  permissions: '0644'
- encoding: b64
  content: ${base64encode(data.template_file.bootstrap-pipeline-vars.rendered)}
  path: /root/bootstrap-vars.yml
  permissions: '0644'

USER_DATA
  }
}

data "template_file" "bastion-config" {
  template = <<CONFIG
---
server:
  host: ${aws_eip.bastion.public_ip}
  fqdn: ${length(var.bastion_host_name) == 0 ? var.vpc_name : var.bastion_host_name}.${var.vpc_dns_zone}
  use_fqdn: ${var.bastion_use_fqdn}
  private_ip: ${aws_network_interface.bastion-public.private_ips[0]}
  lan_interfaces: 'eth0|${aws_network_interface.bastion-public.private_ips[0]}|${cidrnetmask(aws_subnet.dmz.0.cidr_block)}|${aws_subnet.dmz.0.cidr_block}|||,eth1|${aws_network_interface.bastion-private.private_ips[0]}|${cidrnetmask(aws_subnet.engineering.0.cidr_block)}|${var.vpc_cidr}|${cidrnetmask(var.vpc_cidr)}||'

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

data "template_file" "bootstrap-pipeline-vars" {
  template = <<PIPELINE_VARS
---
${file(length(var.bootstrap_var_file) == 0 ? "${path.module}/_placeholder_" : var.bootstrap_var_file)}

environment: ${var.vpc_name}
PIPELINE_VARS
}

resource "random_string" "vpn-admin-password" {
  length  = 16
  special = true
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
# SSH Key
#

resource "tls_private_key" "bastion-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "bastion-ssh-key" {
  content  = "${tls_private_key.bastion-ssh-key.private_key_pem}"
  filename = "${var.ssh_key_file_path}"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.ssh_key_file_path}"
  }
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion"
  public_key = "${tls_private_key.bastion-ssh-key.public_key_openssh}"
}

#
# Outputs
#

output "vpn_admin_password" {
  value = "${random_string.vpn-admin-password.result}"
}

output "bastion_private_ip" {
  value = "${aws_network_interface.bastion-private.private_ips[0]}"
}

output "bastion_public_ip" {
  value = "${aws_eip.bastion.public_ip}"
}
