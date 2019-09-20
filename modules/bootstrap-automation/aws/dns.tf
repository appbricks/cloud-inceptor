#
# Hosted zone for VPC
#

data "aws_route53_zone" "parent" {
  name = "${replace(var.vpc_dns_zone, "/^[-0-9a-zA-Z]+\\./", "")}."
}

#
# Public Zone
#
resource "aws_route53_zone" "vpc-public" {
  name = "${var.vpc_dns_zone}"

  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_route53_record" "vpc-public-ns" {
  zone_id = "${data.aws_route53_zone.parent.zone_id}"
  name    = "${var.vpc_dns_zone}"
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
  name = "${var.vpc_dns_zone}"

  vpc {
    vpc_id = "${aws_vpc.main.id}"
  }

  tags = {
    Name = "${var.vpc_name}"
  }
}

#
# VPC Bastion instance DNS
#

resource "aws_route53_record" "vpc-public" {
  zone_id = "${aws_route53_zone.vpc-public.zone_id}"
  name    = "${var.vpc_dns_zone}."
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.bastion-public.public_ip}"]
}

resource "aws_route53_record" "vpc-admin" {
  count = "${length(var.bastion_host_name) > 0 && !var.bastion_allow_public_ssh ? 1 : 0}"

  zone_id = "${aws_route53_zone.vpc-private.zone_id}"
  name    = "${var.bastion_host_name}.${var.vpc_dns_zone}."

  type = "A"
  ttl  = "300"

  records = ["${local.bastion_admin_itf_ip}"]
}

resource "aws_route53_record" "vpc-mail" {
  count = "${length(var.smtp_relay_host) == 0 ? 0 : 1}"

  zone_id = "${aws_route53_zone.vpc-public.zone_id}"
  name    = "mail.${var.vpc_dns_zone}."
  type    = "A"
  ttl     = "300"
  records = ["${local.bastion_admin_itf_ip}"]
}

resource "aws_route53_record" "vpc-mx" {
  count = "${length(var.smtp_relay_host) == 0 ? 0 : 1}"

  zone_id = "${aws_route53_zone.vpc-public.zone_id}"
  name    = "${var.vpc_dns_zone}."
  type    = "MX"
  ttl     = "300"
  records = ["1 ${aws_route53_record.vpc-public.name}"]
}

resource "aws_route53_record" "vpc-txt" {
  count = "${length(var.smtp_relay_host) == 0 ? 0 : 1}"

  zone_id = "${aws_route53_zone.vpc-public.zone_id}"
  name    = "${var.vpc_dns_zone}."
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 mx -all"]
}
