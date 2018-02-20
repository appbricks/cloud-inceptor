#
# Jumpbox
#

resource "aws_instance" "jumpbox" {
  instance_type = "t2.nano"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.default.key_name}"

  subnet_id              = "${module.vpc.engineering_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.internal.id}"]

  tags {
    Name = "${var.vpc_name}: jumpbox"
  }
}

#
# Jumpbox DNS
#

resource "aws_route53_record" "jumpbox" {
  zone_id = "${aws_route53_zone.vpc-private.zone_id}"
  name    = "jumpbox.${aws_route53_zone.vpc-private.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.jumpbox.private_ip}"]
}

#
# Output
#

output "jumpbox-fqdn" {
  value = "${aws_route53_record.jumpbox.name}"
}
