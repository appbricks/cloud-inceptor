#
# References to the networks created by the VPC module
#

data "google_compute_network" "engineering" {
  name = "${module.vpc.engineering_network_name}"
}

data "google_compute_subnetwork" "engineering" {
  name = "${module.vpc.engineering_subnetwork_name}"
}
