#
# Jumpbox
#

locals {
  local_dns = "${length(var.vpc_internal_dns_zones) > 0 
    ? element(var.vpc_internal_dns_zones, 0) : ""}"

  jumpbox_dns = "${var.deploy_jumpbox && length(local.local_dns) > 0 
    ? format("jumpbox.%s", local.local_dns) : ""}"
  jumpbox_ip = cidrhost(azurerm_subnet.admin.address_prefix, 10)
  jumpbox_dns_record = "${length(local.jumpbox_dns) > 0 
    ? format("%s:%s", local.jumpbox_dns, local.jumpbox_ip) : ""}"
}

resource "azurerm_virtual_machine" "jumpbox" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  name = "${var.vpc_name}-jumpbox"

  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  vm_size               = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.jumpbox-admin[count.index].id]

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.vpc_name}-jumpbox-root"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "40"
  }
  
  os_profile {
    computer_name  = "jumpbox"
    admin_username = "ubuntu"

    custom_data = <<USER_DATA
#cloud-config

write_files:
- encoding: b64
  content: ${base64encode(data.template_file.mount-jumpbox-data-volume.rendered)}
  path: /root/mount-volume.sh
  permissions: '0744'

runcmd: 
- sudo /root/mount-volume.sh
USER_DATA
  }
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys { 
      key_data = tls_private_key.default-ssh-key.public_key_openssh
      path     = "/home/ubuntu/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_network_interface" "jumpbox-admin" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  name = "${var.vpc_name}-jumpbox-admin"
  
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  ip_configuration {
    name                          = "admin"
    subnet_id                     = azurerm_subnet.admin.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.jumpbox_ip
  }

  network_security_group_id = azurerm_network_security_group.admin.id
}

#
# Jumpbox data volume
#

data "template_file" "mount-jumpbox-data-volume" {
  template = file("${path.module}/scripts/mount-volume.sh")

  vars = {
    attached_device_name = "sdc"
    mount_directory      = "/data"
    world_readable       = "true"
  }
}

resource "azurerm_managed_disk" "jumpbox-data" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  name = "${var.vpc_name}-jumpbox-data"

  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.jumpbox_data_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "jumpbox-data" {
  count = length(local.jumpbox_dns) > 0 ? 1 : 0

  managed_disk_id    = azurerm_managed_disk.jumpbox-data[count.index].id
  virtual_machine_id = azurerm_virtual_machine.jumpbox[count.index].id

  lun     = "10"
  caching = "ReadWrite"
}
