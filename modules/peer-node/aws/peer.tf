#
# Peer the ingress and egress VPCs
#

resource "aws_vpc_peering_connection" "peer-nodes" {
  provider = "aws.ingress"
  count    = "${var.create ? 1 : 0}"

  vpc_id      = "${data.aws_vpc.ingress-vpc[0].id}"
  peer_vpc_id = "${data.aws_vpc.egress-vpc[0].id}"
  peer_region = "${var.egress_region}"

  tags = {
    Name = "${var.ingress_vpc_name} - peered to ${var.egress_vpc_name}"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer-nodes" {
  provider = "aws.egress"
  count    = "${var.create ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer-nodes[0].id}"
  auto_accept               = true

  tags = {
    Name = "${var.egress_vpc_name} - peered to ${var.ingress_vpc_name}"
  }
}

# Add route to egress admin network from ingress admin network
resource "aws_route" "ingress-egress-admin" {
  provider = "aws.ingress"
  count    = "${var.create ? length(data.aws_route_tables.ingress-admin[0].ids) : 0}"

  route_table_id            = "${element(flatten(data.aws_route_tables.ingress-admin[0].ids), count.index)}"
  destination_cidr_block    = "${data.aws_vpc.egress-vpc[0].cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer-nodes[0].id}"

  depends_on = [ "aws_vpc_peering_connection.peer-nodes" ]
}

# Add route to ingress admin network from egress admin network
resource "aws_route" "egress-ingress-admin" {
  provider = "aws.egress"
  count    = "${var.create ? length(data.aws_route_tables.egress-admin[0].ids) : 0}"

  route_table_id            = "${element(flatten(data.aws_route_tables.egress-admin[0].ids), count.index)}"
  destination_cidr_block    = "${data.aws_vpc.ingress-vpc[0].cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection_accepter.peer-nodes[0].id}"

  depends_on = [ "aws_vpc_peering_connection_accepter.peer-nodes" ]
}

# Update ingress internal security group to accept all traffic from egress VPC admin subnet
resource "aws_security_group" "ingress-internal" {
  provider = "aws.ingress"
  count    = "${var.create ? 1 : 0}"

  name        = "${var.ingress_vpc_name}: internal allow ${var.egress_vpc_name}"
  description = "Rules to allow traffic from admin network in peered VPC ${var.egress_vpc_name}."
  vpc_id      = "${data.aws_vpc.ingress-vpc[0].id}"

  # Allow all ingress traffic from instances 
  # having same security group
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = "${data.aws_subnet.egress-admin.*.cidr_block}"
  }
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    cidr_blocks = "${data.aws_subnet.egress-admin.*.cidr_block}"
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = "${data.aws_subnet.egress-admin.*.cidr_block}"
  }

  tags = {
    Name = "${var.ingress_vpc_name}: internal allow ${var.egress_vpc_name}"
  }
}

resource "aws_network_interface_sg_attachment" "ingress-bastion-nic" {
  provider = "aws.ingress"
  count    = "${var.create ? 1 : 0}"

  security_group_id    = "${aws_security_group.ingress-internal[0].id}"
  network_interface_id = "${data.aws_network_interface.ingress-bastion-nic[0].id}"
}

# Update egress internal security group to accept all traffic from ingress VPC admin subnet
resource "aws_security_group" "egress-internal" {
  provider = "aws.egress"
  count    = "${var.create ? 1 : 0}"

  name        = "${var.egress_vpc_name}: internal allow ${var.ingress_vpc_name}"
  description = "Rules to allow traffic from admin network in peered VPC ${var.ingress_vpc_name}."
  vpc_id      = "${data.aws_vpc.egress-vpc[0].id}"

  # Allow all ingress traffic from instances 
  # having same security group
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = "${data.aws_subnet.ingress-admin.*.cidr_block}"
  }
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    cidr_blocks = "${data.aws_subnet.ingress-admin.*.cidr_block}"
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = "${data.aws_subnet.ingress-admin.*.cidr_block}"
  }

  tags = {
    Name = "${var.egress_vpc_name}: internal allow ${var.ingress_vpc_name}"
  }
}

resource "aws_network_interface_sg_attachment" "egress-bastion-nic" {
  provider = "aws.egress"
  count    = "${var.create ? 1 : 0}"

  security_group_id    = "${aws_security_group.egress-internal[0].id}"
  network_interface_id = "${data.aws_network_interface.egress-bastion-nic[0].id}"
}
