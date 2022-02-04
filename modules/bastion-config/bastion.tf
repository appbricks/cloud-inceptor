#
# SSH Key
#

resource "tls_private_key" "bastion-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

#
# Bastion configuration templates
#

locals {
  bastion_internal_ip = length(var.bastion_admin_itf_ip) > 0 ? var.bastion_admin_itf_ip : var.bastion_dmz_itf_ip

  admin_email = "${var.bastion_admin_user}@${var.vpc_dns_zone}"

  # Create shorter email key if it is too long when 
  # vpc dns is included, as vpn cert creation limits 
  # length of string accepted.
  vpn_email_key = length(local.admin_email) > 40 ? join("@", tolist([var.bastion_admin_user, var.vpc_name])) : local.admin_email
}

data "template_cloudinit_config" "bastion-cloudinit" {
  gzip          = var.compress_cloudinit
  base64_encode = var.compress_cloudinit

  part {
    content = <<USER_DATA
#cloud-config

users:
- name: ${var.bastion_admin_user}
  sudo: ALL=(ALL) NOPASSWD:ALL
  ssh_authorized_keys:
  - ${tls_private_key.bastion-ssh-key.public_key_openssh}

write_files:
# Service configuration
- encoding: gzip+base64
  content: ${base64gzip(data.template_file.bastion-config.rendered)}
  path: /usr/local/etc/bastion-config.yml
  permissions: '0744'

# Web Server SSL certificates
- encoding: gzip+base64
  content: ${base64gzip(local.root_ca_cert)}
  path: /etc/ssl/certs/bastion_ca.pem
  permissions: '0644'
- encoding: gzip+base64
  content: ${base64gzip(local.root_ca_key)}
  path: /etc/ssl/certs/bastion_ca_key.pem
  permissions: '0644'
- encoding: gzip+base64
  content: ${base64gzip(tls_locally_signed_cert.bastion.cert_pem)}
  path: /etc/ssl/certs/bastion_cert.pem
  permissions: '0644'
- encoding: gzip+base64
  content: ${base64gzip(tls_private_key.bastion.private_key_pem)}
  path: /etc/ssl/private/bastion_key.pem
  permissions: '0644'
- encoding: gzip+base64
  content: ${base64gzip(var.mycs_node_private_key)}
  path: /etc/mycs/node-private-key.pem
  owner: mycs:root
  permissions: '0600'

# Web Server home page
- encoding: gzip+base64
  content: ${base64gzip(data.template_file.www-static-index.rendered)}
  path: /var/www/html/index.html
  permissions: '0644'

# Bootstrap Pipeline
- encoding: gzip+base64
  content: ${base64gzip(file(length(var.bootstrap_pipeline_file) == 0 ? "${path.module}/_placeholder_" : var.bootstrap_pipeline_file))}
  path: /root/bootstrap.yml
  permissions: '0644'
- encoding: gzip+base64
  content: ${base64gzip(data.template_file.bootstrap-pipeline-vars.rendered)}
  path: /root/bootstrap-vars.yml
  permissions: '0644'

runcmd:
- sudo -i -- <<INIT
    [[ -e /usr/local/etc/.init_instance_complete ]] \
      || nohup /usr/local/lib/cloud-inceptor/init_instance 2>&1 | tee /var/log/init_instance.log &
  INIT

USER_DATA
  }
}

data "template_file" "bastion-config" {
  template = <<CONFIG
---
mycs:
  node_id_key: '${var.mycs_node_id_key}'
  key_timeout: 300000
  auth_retry_timer: 500
  auth_timeout: 10000
  db_refresh_timer: 30000
  idle_shutdown_time: ${var.vpn_idle_shutdown_time}
  event_buffer_size: 1000
  num_event_workers: 20
  event_publish_timeout: 5000

server:
  time_zone: '${var.time_zone}'
  host: '${var.bastion_public_ip}'
  fqdn: '${var.bastion_fqdn}'
  use_fqdn: ${var.bastion_use_fqdn}
  certify_bastion: ${var.certify_bastion ? "yes" : "no"}
  dmz_itf_ip: '${var.bastion_dmz_itf_ip}'
  lan_interfaces: '${join(",", var.bastion_nic_config)}'
  dns_resolvers: '${length(var.bastion_dns) == 0 ? local.bastion_internal_ip: var.bastion_dns}'
  enable_dhcpd: ${var.enable_bastion_as_dhcpd}
  admin_ssh_port: ${var.bastion_admin_ssh_port}
  admin_user: '${var.bastion_admin_user}'
  admin_passwd: '${random_string.bastion-admin-password.result}'
  admin_ssh_public_key: ${tls_private_key.bastion-ssh-key.public_key_openssh}
  docker_mount_path: /data

data:
  attached_device_name: ${var.data_volume_name}
  mount_directory: /data
  world_readable: false

powerdns:
  dns_zones: '${join(" ", var.vpc_internal_dns_zones)}'
  dns_records: '${join(" ", var.vpc_internal_dns_records)}'
  allowed_subnets: '${var.vpc_cidr},${var.vpn_network}'
  ns_ip: '${local.bastion_internal_ip}'
  api_key: '${random_string.powerdns-api-key.result}'

smtp:
  relay_host: '${var.smtp_relay_host}'
  relay_port: ${var.smtp_relay_port}
  relay_api_key: '${var.smtp_relay_api_key}'
  internal_smtp_host: '${local.bastion_internal_ip}'
  internal_smtp_port: 2525
  networks: '172.16.0.0/12 ${var.vpc_cidr} ${var.bastion_public_ip}'

webserver:
  https_port: ${var.bastion_admin_api_port}
  static_content_port: 8080
  api_service_port: 9080

vpn:
  type: '${var.vpn_type}'
  subnet: '${var.vpn_network}'
  netmask: '${cidrnetmask(var.vpn_network)}'
  protected_subnet: '${var.vpn_protected_network}'
  server_domain: '${var.vpc_dns_zone}'
  server_description: '${var.vpc_name}'
  tunnel_client_traffic: ${var.vpn_tunnel_all_traffic}
  idle_action: ${var.vpn_idle_action}
  openvpn:
    port: ${var.ovpn_service_port}
    protocol: ${var.ovpn_protocol}
  tunnel_vpn:
    port_start: ${var.tunnel_vpn_port_start}
    port_end: ${var.tunnel_vpn_port_end}
  wireguard:
    itf_name: 'wg0'
    host_ip: '${local.bastion_internal_ip}'
    listen_port: ${var.wireguard_service_port}
    subnet_ip: '${var.wireguard_subnet_ip}'
  vpn_cert:
    name: '${var.vpc_name}_VPN'
    org: '${var.organization_name}'
    email: '${local.vpn_email_key}'
    city: '${var.locality}'
    province: '${var.province}'
    country: '${var.country}'
    ou: '${var.vpc_name}'
    cn: '${var.vpc_dns_zone}'
  users: '${var.vpn_users}'

concourse:
  port: ${length(var.concourse_server_port) == 0 ? "" : var.concourse_server_port}
  password: '${var.concourse_admin_password}'
  vpc_name: '${var.vpc_name}'
  pipeline_automation_path: '${var.pipeline_automation_path}'
  notification_email: '${var.notification_email}'
CONFIG
}

data "template_file" "www-static-index" {
  template = file("${path.module}/www-static-home/index.html")

  vars = {
    environment = var.vpc_name
    bastion_fqdn = var.bastion_fqdn
  }
}

data "template_file" "bootstrap-pipeline-vars" {
  template = var.bootstrap_pipeline_vars
}

resource "random_string" "bastion-admin-password" {
  length  = 32
  special = true
}

resource "random_string" "powerdns-api-key" {
  length           = 32
  special          = true
  override_special = "@#%&*()-_=+[]{}<>:?"
}
