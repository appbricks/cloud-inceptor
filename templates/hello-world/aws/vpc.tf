#
# Pave VPC with the foundation network architecture and resources
# 

module "vpc" {
  source = "../../../modules/aws"

  vpc_name     = "${var.vpc_name}"
  vpc_dns_zone = "${var.dns_zone_name}"

  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  bootstrap_pipeline_file = "${var.bootstrap_pipeline_file}"
  bootstrap_var_file      = "${var.bootstrap_var_file}"
}

resource "aws_route53_record" "bastion-public" {
  zone_id = "${aws_route53_zone.vpc-public.zone_id}"
  name    = "${var.vpc_name}.${aws_route53_zone.vpc-public.name}"
  type    = "A"
  ttl     = "300"
  records = ["${module.vpc.bastion-public-ip}"]
}

resource "aws_route53_record" "bastion-private" {
  zone_id = "${aws_route53_zone.vpc-private.zone_id}"
  name    = "${var.vpc_name}.${aws_route53_zone.vpc-private.name}"
  type    = "A"
  ttl     = "300"
  records = ["${module.vpc.bastion-private-ip}"]
}

output "bastion-fqdn" {
  value = "${aws_route53_record.bastion-public.name}"
}

output "vpn-admin-password" {
  value = "${module.vpc.vpn-admin-password}"
}
