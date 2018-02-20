#
# References to the networks created by the VPC module
#

data "google_compute_network" "engineering" {
  name = "${module.vpc.engineering_network_name}"
}

data "google_compute_subnetwork" "engineering" {
  name = "${module.vpc.engineering_subnetwork_name}"
}

#
# Add network firewall rules
#

resource "google_compute_firewall" "engineering-allow-all-vpc" {
  name    = "${var.vpc_name}-engineering-allow-all-vpc"
  network = "${data.google_compute_network.engineering.name}"

  allow {
    protocol = "all"
  }

  source_ranges = ["${var.vpc_cidr}"]
  target_tags   = ["allow-all-vpc"]
}
