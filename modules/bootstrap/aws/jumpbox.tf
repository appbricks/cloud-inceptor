#
# Jumpbox
#

resource "aws_instance" "jumpbox" {
  instance_type = "t2.nano"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.default.key_name}"

  subnet_id         = "${module.vpc.admin_subnets[0]}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  vpc_security_group_ids = ["${aws_security_group.internal.id}"]

  tags {
    Name = "${var.vpc_name}: jumpbox"
  }

  user_data = <<USERDATA
#cloud-config

write_files:
- encoding: b64
  content: ${base64encode(data.template_file.mount-volume.rendered)}
  path: /root/mount-volume.sh
  permissions: '0744'

runcmd: 
- /root/mount-volume.sh
USERDATA
}

data "template_file" "mount-volume" {
  template = "${file("${path.module}/scripts/mount-volume.sh")}"

  vars {
    attached_device_name = "${var.data_volume_device_name}"
    mount_directory      = "/data"
  }
}

#
# Persistant disk for data storage
#
resource "aws_ebs_volume" "jumpbox-data" {
  size              = 160
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_volume_attachment" "jumpbox-data" {
  device_name  = "${var.data_volume_device_name}"
  volume_id    = "${aws_ebs_volume.jumpbox-data.id}"
  instance_id  = "${aws_instance.jumpbox.id}"
  force_detach = true
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
