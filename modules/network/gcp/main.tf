#
# Availability Zones in current region
#

data "google_compute_zones" "available" {
  region = "${var.region}"
}
