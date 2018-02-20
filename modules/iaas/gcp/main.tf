#
# Availability Zones in current region
#

data "google_compute_zones" "available" {
  region = "${var.region}"
}

#
# Standard Ubuntu image
#

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-1604-lts"
  project = "ubuntu-os-cloud"
}
