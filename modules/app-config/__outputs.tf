#
# Module Outputs
#

# Cloud-Init configuration file setting 
# up the Bastion instance on first boot
output "app_cloud_init_config" {
  value = data.template_cloudinit_config.app-cloudinit.rendered
}
