#
# NAT instances and routing for resources 
# within the admin network. Resources
# that require NATing should be tagged with
# the label 'nat-<VPC_NAME>-<REGION>.
#

resource "google_compute_instance" "nat-gateway-admin" {
  count = "${min(var.max_azs, length(data.google_compute_zones.available.names))}"

  name         = "${var.vpc_name}-nat-gateway-admin-${count.index}"
  machine_type = "g1-small"
  zone         = "${data.google_compute_zones.available.names[count.index]}"

  allow_stopping_for_update = true

  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.admin.self_link}"

    access_config {
      // Ephemeral
    }
  }

  metadata_startup_script = <<EOF
#!/bin/bash -xe
sysctl -w net.ipv4.ip_forward=1
sed -i= 's/^[# ]*net.ipv4.ip_forward=[[:digit:]]/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
apt-get update
apt-get upgrade
EOF
}

resource "google_compute_route" "nat-route-admin" {
  count = "${min(var.max_azs, length(data.google_compute_zones.available.names))}"

  name                   = "${var.vpc_name}-nat-route-admin-${count.index}"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.admin.name}"
  next_hop_instance      = "${google_compute_instance.nat-gateway-admin.name}"
  next_hop_instance_zone = "${data.google_compute_zones.available.names[count.index]}"
  priority               = 800

  tags = ["nat-${var.vpc_name}-${var.region}"]
}
