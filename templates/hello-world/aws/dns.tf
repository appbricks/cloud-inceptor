#
# Hosted zone for VPC
#

data "aws_route53_zone" "parent" {
  name = "${replace(var.dns_zone_name, "/^[-0-9a-zA-Z]+\\./", "")}."
}

#
# Public Zone
#
resource "aws_route53_zone" "vpc-public" {
  name = "${var.dns_zone_name}"

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_route53_record" "vpc-public" {
  zone_id = "${data.aws_route53_zone.parent.zone_id}"
  name    = "${var.dns_zone_name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.vpc-public.name_servers.0}",
    "${aws_route53_zone.vpc-public.name_servers.1}",
    "${aws_route53_zone.vpc-public.name_servers.2}",
    "${aws_route53_zone.vpc-public.name_servers.3}",
  ]
}

#
# Private Zone
#
resource "aws_route53_zone" "vpc-private" {
  name   = "${var.dns_zone_name}"
  vpc_id = "${module.vpc.vpc_id}"

  tags {
    Name = "${var.vpc_name}"
  }
}
