#
# Jumpbox
#

locals {
  local_dns = (
    length(var.vpc_internal_dns_zones) > 0 
      ? element(var.vpc_internal_dns_zones, 0) 
      : ""
  )
  jumpbox_dns = (
    var.deploy_jumpbox && length(local.local_dns) > 0 
      ? format("jumpbox.%s", local.local_dns) 
      : ""
  )
  jumpbox_dns_record = (
    length(local.jumpbox_dns) > 0 
      ? format("%s:%s", local.jumpbox_dns, aws_instance.jumpbox[0].private_ip) 
      : ""
  )
}

resource "aws_instance" "jumpbox" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  instance_type = "t4g.nano"
  ami           = data.aws_ami.ubuntu.id
  key_name      = aws_key_pair.default.key_name

  subnet_id         = (
    var.configure_admin_network
      ? aws_subnet.admin[0].id
      : aws_subnet.dmz[0].id
  )
  availability_zone = data.aws_availability_zones.available.names[0]

  vpc_security_group_ids = [aws_security_group.internal.id]

  tags = {
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
- sudo /root/mount-volume.sh
USERDATA
}

data "template_file" "mount-volume" {
  template = file("${path.module}/scripts/mount-volume.sh")

  vars = {
    attached_device_name = local.jumpbox_data_disk_device_name
    mount_directory      = "/data"
    world_readable       = "true"
  }
}

#
# Persistant disk for data storage
#

locals {
  jumpbox_data_disk_device_name = "xvdf"
}

resource "aws_ebs_volume" "jumpbox-data" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  size              = tonumber(var.jumpbox_data_disk_size)
  type              = "standard"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.vpc_name}: jumpbox data disk"
  }
}

resource "aws_volume_attachment" "jumpbox-data" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  device_name  = local.jumpbox_data_disk_device_name
  volume_id    = aws_ebs_volume.jumpbox-data[0].id
  instance_id  = aws_instance.jumpbox[0].id
  force_detach = true
}

#
# Jumpbox DNS
#

resource "aws_route53_record" "jumpbox" {
  count = var.attach_dns_zone && length(local.jumpbox_dns) > 0 ? 1 : 0

  zone_id = aws_route53_zone.vpc-private[0].zone_id
  name    = "jumpbox.${aws_route53_zone.vpc-private[0].name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jumpbox[0].private_ip]
}
