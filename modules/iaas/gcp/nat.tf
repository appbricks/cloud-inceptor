#
# NAT instances and routing
#

resource "google_compute_instance" "nat-gateway" {
  count = "${min(var.max_azs, length(data.google_compute_zones.available.names))}"

  name           = "${var.vpc_name}-nat-gateway-${count.index}"
  machine_type   = "n1-standard-2"
  zone           = "${data.google_compute_zones.available.names[count.index]}"
  can_ip_forward = true
  tags           = ["${compact(concat(list("nat-${var.vpc_name}-${var.region}"), var.tags_nat))}"]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.ubuntu.self_link}"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.dmz.self_link}"

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

resource "google_compute_route" "nat-gateway" {
  count = "${min(var.max_azs, length(data.google_compute_zones.available.names))}"

  name                   = "${var.vpc_name}-nat-route-${count.index}"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.dmz.name}"
  next_hop_instance      = "${google_compute_instance.nat-gateway.name}"
  next_hop_instance_zone = "${data.google_compute_zones.available.names[count.index]}"
  priority               = 800
  tags                   = ["${compact(concat(list("${var.vpc_name}-${var.region}"), var.tags_common))}"]
}

#
# Network firewall rule to allow all traffic
#

resource "google_compute_firewall" "nat-gateway" {
  name    = "${var.vpc_name}-nat-allow-all"
  network = "${google_compute_network.dmz.name}"

  allow {
    protocol = "all"
  }

  source_tags = ["${compact(concat(list("nat-${var.vpc_name}-${var.region}"), var.tags_common))}"]
  target_tags = ["${compact(concat(list("nat-${var.vpc_name}-${var.region}"), var.tags_common))}"]
}
