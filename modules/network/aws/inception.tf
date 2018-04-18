#
# Inception bastion instance configuration
# 
# When debugging replace source github path 
# with relative path filesystem path.
#
# - "../../inception/gcp"
#

module "inception" {
  source = "github.com/appbricks/cloud-inceptor//modules/inception/aws"

  company_name      = "${var.company_name}"
  organization_name = "${var.organization_name}"
  locality          = "${var.locality}"
  province          = "${var.province}"
  country           = "${var.country}"

  vpc_id       = "${data.aws_vpc.main.id}"
  vpc_name     = "${var.vpc_name}"
  vpc_dns_zone = "${var.vpc_dns_zone}"
  vpc_cidr     = "${var.vpc_cidr}"

  dmz_subnet_ids           = "${aws_subnet.dmz.*.id}"
  dmz_subnet_cidrs         = "${aws_subnet.dmz.*.cidr_block}"
  admin_subnet_ids   = "${aws_subnet.admin.*.id}"
  admin_subnet_cidrs = "${aws_subnet.admin.*.cidr_block}"

  bastion_instance_type = "${var.bastion_instance_type}"
  bastion_image_name    = "${var.bastion_image_name}"
  bastion_host_name     = "${var.bastion_host_name}"
  bastion_use_fqdn      = "${var.bastion_use_fqdn}"

  squidproxy_server_port = "${var.squidproxy_server_port}"

  vpn_server_port        = "${var.vpn_server_port}"
  vpn_protocol           = "${var.vpn_protocol}"
  vpn_network            = "${var.vpn_network}"
  vpn_network_dns        = "${var.vpn_network_dns}"
  vpn_tunnel_all_traffic = "${var.vpn_tunnel_all_traffic}"
  vpn_users              = "${var.vpn_users}"

  concourse_server_port    = "${var.concourse_admin_password}"
  concourse_admin_password = "${var.concourse_admin_password}"

  bootstrap_pipeline_file = "${var.bootstrap_pipeline_file}"
  bootstrap_var_file      = "${var.bootstrap_var_file}"
}
