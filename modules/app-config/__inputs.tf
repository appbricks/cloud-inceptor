#
# App service keys
#
variable "mycs_cloud_public_key_id" {
  default = "NA"
}

variable "mycs_cloud_public_key" {
  default = "NA"
}

variable "mycs_app_private_key" {
  default = "NA"
}

variable "mycs_app_id_key" {
  default = "NA"
}

variable "mycs_space_ca_root" {
  default = "NA"
}

#
# App install
#

# Zip archive of all additional app files. An
# install script can also be provided instead
# of the zip of script files that include the
# install script
variable "app_file_archive" {
  default = "/NA"
}

# Optional app install script if not included
# in the above archive
variable app_install_script {
  default = "/NA"
}

# Name of app install script if within the 
# app_file_archive zip. Otherwise the app 
# install will look for a default script 
# provided via the above app_install_script 
# variable
variable "app_install_script_name" {
  default = "install.sh"
}

#
# App node configuration
#
variable "vpn_idle_shutdown_time" {
  default = 10
}

#
# Compress cloud-init data
#
variable "compress_cloudinit" {
  default = true
}
