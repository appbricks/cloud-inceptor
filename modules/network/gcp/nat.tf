#
# NAT instances and routing for resources 
# within the engineering network. Resources
# that require NATing should be tagged with
# the label 'nat-<VPC_NAME>-<REGION>.
#

resource "google_compute_instance" "nat-gateway-engineering" {
  count = "${min(var.max_azs, length(data.google_compute_zones.available.names))}"

  name           = "${var.vpc_name}-nat-gateway-engineering-${count.index}"
  machine_type   = "g1-small"
  zone           = "${data.google_compute_zones.available.names[count.index]}"
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.engineering.self_link}"

    access_config {
      // Ephemeral
    }
  }

  metadata_startup_script = <<EOF
#! /bin/bash
sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF
}

resource "google_compute_route" "nat-route-engineering" {
  count = "${min(var.max_azs, length(data.google_compute_zones.available.names))}"

  name                   = "${var.vpc_name}-nat-route-engineering-${count.index}"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.engineering.name}"
  next_hop_instance      = "${google_compute_instance.nat-gateway-engineering.name}"
  next_hop_instance_zone = "${data.google_compute_zones.available.names[count.index]}"
  priority               = 800

  tags = ["nat-${var.vpc_name}-${var.region}"]
}
