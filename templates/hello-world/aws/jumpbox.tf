#
# Jumpbox
#

resource "aws_instance" "jumpbox" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.jumpbox.id}"
  key_name      = "${aws_key_pair.default.key_name}"

  subnet_id              = "${module.vpc.engineering_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.internal.id}"]

  tags {
    Name = "${var.vpc_name}: jumpbox"
  }
}

#
# AMI
#

data "aws_ami" "jumpbox" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
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
