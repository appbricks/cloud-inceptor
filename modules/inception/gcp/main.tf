#
# Availability Zones in current region
#

data "google_compute_zones" "available" {
  region = "${var.region}"
}

#
# References to the networks created by the VPC module
#

data "google_compute_network" "dmz" {
  name = "${var.dmz_network}"
}

data "google_compute_subnetwork" "dmz" {
  name = "${var.dmz_subnetwork}"
}

data "google_compute_network" "engineering" {
  name = "${var.engineering_network}"
}

data "google_compute_subnetwork" "engineering" {
  name = "${var.engineering_subnetwork}"
}
