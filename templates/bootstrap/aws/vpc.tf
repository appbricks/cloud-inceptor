#
# Pave VPC with the foundation network architecture and resources
# 
# When debugging replace source github path 
# with relative path filesystem path.
#
# - "../../../modules/network/gcp"
#

module "vpc" {
  source = "github.com/appbricks/cloud-inceptor//modules/network/aws"

  vpc_id       = "${aws_vpc.main.id}"
  vpc_name     = "${var.vpc_name}"
  vpc_dns_zone = "${var.vpc_dns_zone}"
  vpc_cidr     = "${var.vpc_cidr}"
  subnet_bits  = "${var.subnet_bits}"
  subnet_start = "${var.subnet_start}"
  max_azs      = "${var.max_azs}"

  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  vpn_server_port        = "${var.vpn_server_port}"
  vpn_protocol           = "${var.vpn_protocol}"
  vpn_network            = "${var.vpn_network}"
  vpn_network_dns        = "${var.vpn_network_dns}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_users              = "${var.vpn_users}"

  bootstrap_pipeline_file = "${var.bootstrap_pipeline_file}"
  bootstrap_var_file      = "${var.bootstrap_var_file}"
}

resource "aws_route53_record" "bastion-public" {
  zone_id = "${aws_route53_zone.vpc-public.zone_id}"
  name    = "${module.vpc.bastion_fqdn}"
  type    = "A"
  ttl     = "300"
  records = ["${module.vpc.bastion_public_ip}"]
}

resource "aws_route53_record" "bastion-private" {
  zone_id = "${aws_route53_zone.vpc-private.zone_id}"
  name    = "${module.vpc.bastion_fqdn}"
  type    = "A"
  ttl     = "300"
  records = ["${module.vpc.bastion_private_ip}"]
}

output "bastion-fqdn" {
  value = "${aws_route53_record.bastion-public.name}"
}

output "vpn-admin-password" {
  value = "${module.vpc.vpn_admin_password}"
}
