#
# App instance configuration template
#

locals {
  # templates
  mycs_app_install_script = templatefile(
    "${path.module}/mycs-app-install.sh",
    {
      mycs_app_version = var.mycs_app_version
      mycs_app_data_dir = var.mycs_app_data_dir
      app_install_script = var.app_install_script_name
    }
  )
}

data "cloudinit_config" "app-cloudinit" {
  gzip          = var.compress_cloudinit
  base64_encode = var.compress_cloudinit

  part {
    content = <<USER_DATA
#cloud-config

write_files:
# Service configuration
- encoding: gzip+base64
  content: ${base64gzip(file(local_file.mycs-app-config.filename))}
  path: /etc/mycs/config.yml
  permissions: '0600'

- encoding: gzip+base64
  content: ${base64gzip(var.mycs_cloud_public_key)}
  path: /etc/mycs/mycs-key-${var.mycs_cloud_public_key_id}.pem
  permissions: '0600'

- encoding: gzip+base64
  content: ${base64gzip(var.mycs_app_private_key)}
  path: /etc/mycs/node-private-key.pem
  permissions: '0600'

- encoding: gzip+base64
  content: ${base64gzip(var.mycs_space_ca_root)}
  path: /etc/mycs/local-ca-root.pem
  permissions: '0600'

- encoding: gzip+base64
  content: ${base64gzip(local.mycs_app_install_script)}
  path: /usr/local/lib/mycs/mycs-app-install.sh
  permissions: '0744'

- encoding: base64
  content: ${fileexists(var.app_file_archive) ? filebase64(var.app_file_archive) : base64encode("")}
  path: /usr/local/lib/mycs/app-scripts.zip
  permissions: '0644'

- encoding: base64
  content: ${fileexists(var.app_install_script) ? filebase64(var.app_install_script) : base64encode("")}
  path: /usr/local/lib/mycs/${var.app_install_script_name}
  permissions: '0744'

runcmd:
- sudo -i -- <<INIT
    [[ -e /usr/local/lib/mycs/.installed ]] \
      || nohup /usr/local/lib/mycs/mycs-app-install.sh 2>&1 | tee /var/log/mycs-app-install.log &
  INIT

USER_DATA

  }
}

resource "local_file" "mycs-app-config" {
  content = <<CONFIG
---
mycs:
  node_id_key: '${var.mycs_app_id_key}'
  key_timeout: 300000
  auth_retry_timer: 500
  auth_timeout: 10000
  idle_shutdown_time: ${var.app_idle_shutdown_time}
  num_event_workers: 20
  event_buffer_size: 1000
  event_publish_timeout: 5000

data:
  mount_directory: ${var.mycs_app_data_dir}

network:

application:
  exec_cmd: '${var.app_exec_cmd}'
  cmd_arguments: ${jsonencode(var.app_cmd_arguments)}
  env_arguments: ${jsonencode(var.app_env_arguments)}
  work_directory: '${var.app_work_directory}'
  stop_timeout: ${var.app_stop_timeout}

CONFIG

  filename = "${path.cwd}/.terraform/tmp/mycs-app-config.yml"
}
