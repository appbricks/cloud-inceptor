#
# VPC subnets
#

resource "aws_subnet" "dmz" {
  count = "${min(var.max_azs, length(data.aws_availability_zones.available.names))}"

  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  # Distinct x.x.x.x/24 network for each AZ from subnet start
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, var.subnet_start + count.index)}"

  tags {
    Name = "${var.vpc_name}: dmz subnet ${count.index}"
  }
}

resource "aws_subnet" "engineering" {
  count = "${min(var.max_azs, length(data.aws_availability_zones.available.names))}"

  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  # Distinct x.x.x.x/24 for each AZ after allowing space 
  # for all possible DMZ subnets across all AZs of region
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, var.subnet_start + length(data.aws_availability_zones.available.names) + count.index)}"

  tags {
    Name = "${var.vpc_name}: engineering subnet ${count.index}"
  }
}

#
# VPC internet gateway
#

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}: internet gateway"
  }
}

resource "aws_route_table" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.vpc_name}: internet gateway route"
  }
}

#
# VPC NAT gateway
#

resource "aws_eip" "nat" {
  count = "${min(var.max_azs, length(data.aws_availability_zones.available.names))}"
  vpc   = true
}

resource "aws_nat_gateway" "nat" {
  count = "${min(var.max_azs, length(data.aws_availability_zones.available.names))}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.dmz.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "nat" {
  count = "${min(var.max_azs, length(data.aws_availability_zones.available.names))}"

  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags {
    Name = "${var.vpc_name}: nat ${count.index} gateway route"
  }
}

#
# VPC Route tables
#

resource "aws_route_table_association" "dmz" {
  count = "${min(var.max_azs, length(data.aws_availability_zones.available.names))}"

  subnet_id      = "${element(aws_subnet.dmz.*.id, count.index)}"
  route_table_id = "${aws_route_table.igw.id}"
}

resource "aws_route_table_association" "engineering" {
  count = "${min(var.max_azs, length(data.aws_availability_zones.available.names))}"

  subnet_id      = "${element(aws_subnet.engineering.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.nat.*.id, count.index)}"
}

#
# Outputs
#

output dmz_subnets {
  value = "${aws_subnet.dmz.*.id}"
}

output engineering_subnets {
  value = "${aws_subnet.engineering.*.id}"
}
