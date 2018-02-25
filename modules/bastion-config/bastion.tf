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

network:
  config: disabled

USER_DATA
  }
}

data "template_file" "bastion-config" {
  template = <<CONFIG
---
server:
  host: ${var.bastion_public_ip}
  fqdn: ${var.bastion_fqdn}
  use_fqdn: ${var.bastion_use_fqdn}
  private_ip: ${var.bastion_nic1_private_ip}
  lan_interfaces: '${var.bastion_nic1_private_ip}|${var.bastion_nic1_netmask}|${var.bastion_nic1_lan_cidr}|${var.bastion_nic1_lan_netmask}|${var.bastion_nic1_lan_gateway}|,${var.bastion_nic2_private_ip}|${var.bastion_nic2_netmask}|${var.bastion_nic2_lan_cidr}|${var.bastion_nic2_lan_netmask}|${var.bastion_nic2_lan_gateway}|'

openvpn:
  port: ${var.vpn_server_port}
  protocol: ${var.vpn_protocol}
  subnet: ${var.vpn_network}
  netmask: ${cidrnetmask(var.vpn_network)}
  admin_passwd: ${random_string.vpn-admin-password.result}
  dns_servers: ${var.vpn_network_dns}
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
  port: ${length(var.concourse_server_port) == 0 ? "" : "127.0.0.1:${var.concourse_server_port}"}
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
${var.bootstrap_pipeline_vars}

# VPC Variables
environment: ${var.vpc_name}
region: ${var.region}

dmz_network: ${var.dmz_network}
dmz_subnetwork: ${var.dmz_subnetwork}
engineering_network: ${var.engineering_network}
engineering_subnetwork: ${var.engineering_subnetwork}
PIPELINE_VARS
}

resource "random_string" "vpn-admin-password" {
  length  = 16
  special = true
}
