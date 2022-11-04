#
# Inception Bastion instance
#

resource "azurerm_virtual_machine" "bastion" {
  name = element(split(".", var.vpc_dns_zone), 0)

  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  vm_size = var.bastion_instance_type

  network_interface_ids = [
    azurerm_network_interface.bastion-dmz.id,
    azurerm_network_interface.bastion-admin.id
  ]
  primary_network_interface_id = azurerm_network_interface.bastion-dmz.id

  delete_os_disk_on_termination = true

  storage_image_reference {
    id = var.bastion_use_managed_image ? data.azurerm_image.bastion.0.id : azurerm_image.bastion.0.id
  }
  storage_os_disk {
    name              = "${var.vpc_name}-bastion-root"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = var.bastion_root_disk_size
  }
  
  os_profile {
    computer_name  = element(split(".", var.vpc_dns_zone), 0)
    admin_username = var.bastion_admin_user

    custom_data = module.config.bastion_cloud_init_config
  }
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys { 
      key_data = module.config.bastion_openssh_public_key
      path     = "/home/${var.bastion_admin_user}/.ssh/authorized_keys"
    }    
  }
}

#
# Attached disk for saving persistant data. This disk needs to be
# large enough for any installation packages concourse downloads.
#

resource "azurerm_managed_disk" "bastion-data" {
  name = "${var.vpc_name}-bastion-data"

  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.bastion_data_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "bastion-data" {
  managed_disk_id    = azurerm_managed_disk.bastion-data.id
  virtual_machine_id = azurerm_virtual_machine.bastion.id

  lun     = "10"
  caching = "ReadWrite"
}

#
# Image
#

# Lookup managed image in source resource group
data "azurerm_image" "bastion" {
  count = var.bastion_use_managed_image ? 1 : 0

  name                = "${var.bastion_image_name}_${var.region}"
  resource_group_name = var.source_resource_group
}

# Create image from given unmanaged disk image blob uri
resource "azurerm_image" "bastion" {
  count = var.bastion_use_managed_image ? 0 : 1

  name                = "${var.bastion_image_name}_${var.region}"
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = azurerm_storage_blob.bastion-image-vhd.0.url
  }

  lifecycle {
    ignore_changes = [os_disk]
  }  
}

resource "azurerm_storage_blob" "bastion-image-vhd" {
  count = var.bastion_use_managed_image ? 0 : 1

  name = "${var.bastion_image_name}.vhd"

  storage_account_name   = azurerm_storage_account.bootstrap-storage-account.name
  storage_container_name = azurerm_storage_container.bastion-image-storage-container.0.name

  type       = "Block"
  source_uri = "https://${var.bastion_image_storage_account_prefix}${local.storage_region}.blob.core.windows.net/${var.bastion_image_container}/${var.bastion_image_name}.vhd"

  lifecycle {
    ignore_changes = [type]
  }
}

resource "azurerm_storage_container" "bastion-image-storage-container" {
  count = var.bastion_use_managed_image ? 0 : 1

  name = "images"

  storage_account_name  = azurerm_storage_account.bootstrap-storage-account.name
  container_access_type = "private"
}

#
# Networking
#

resource "azurerm_public_ip" "bastion-public" {
  name = "${var.vpc_name}-bastion-public"

  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  allocation_method   = "Static"
}

resource "azurerm_network_interface" "bastion-dmz" {
  name = "${var.vpc_name}-bastion-dmz"

  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  ip_configuration {
    name                          = "dmz"
    subnet_id                     = azurerm_subnet.dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.dmz.address_prefix, -3)

    public_ip_address_id = azurerm_public_ip.bastion-public.id
  }

  network_security_group_id = azurerm_network_security_group.bastion-dmz.id
}

resource "azurerm_network_interface" "bastion-admin" {
  name = "${var.vpc_name}-bastion-admin"
  
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  ip_configuration {
    name                          = "dmz"
    subnet_id                     = azurerm_subnet.admin.id
    private_ip_address_allocation = "Static"
    private_ip_address            =  cidrhost(azurerm_subnet.admin.address_prefix, -3)
  }

  network_security_group_id = azurerm_network_security_group.bastion-admin.id
}

#
# Security (Firewall rules for the inception bastion instance)
#

resource "azurerm_network_security_group" "bastion-dmz" {
  name = "${var.vpc_name}-bastion-dmz"
  
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name
}

resource "azurerm_network_security_group" "bastion-admin" {
  name = "${var.vpc_name}-bastion-admin"
  
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name
}

resource "azurerm_network_security_rule" "bastion-http" {
  name = "${var.vpc_name}-bastion-http"

  network_security_group_name = azurerm_network_security_group.bastion-dmz.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Allow"
  protocol  = "tcp"
  priority  = "500"
  direction = "Inbound"
  
  source_port_range     = "*"
  source_address_prefix = "0.0.0.0/0"

  destination_port_ranges    = ["80", "443"]
  destination_address_prefix = azurerm_network_interface.bastion-dmz.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-ssh" {
  count = var.bastion_allow_public_ssh ? 1 : 0 

  name = "${var.vpc_name}-bastion-ssh"

  network_security_group_name = azurerm_network_security_group.bastion-dmz.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Allow"
  protocol  = "tcp"
  priority  = "501"
  direction = "Inbound"
  
  source_port_range     = "*"
  source_address_prefix = "0.0.0.0/0"

  destination_port_range     = var.bastion_admin_ssh_port
  destination_address_prefix = azurerm_network_interface.bastion-dmz.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-openvpn" {
  count = var.vpn_type == "openvpn" && length(var.ovpn_service_port) > 0 ? 1 : 0 

  name = "${var.vpc_name}-bastion-openvpn"

  network_security_group_name = azurerm_network_security_group.bastion-dmz.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Allow"
  protocol  = var.ovpn_protocol
  priority  = "502"
  direction = "Inbound"
  
  source_port_range     = "*"
  source_address_prefix = "0.0.0.0/0"

  destination_port_range     = var.ovpn_service_port
  destination_address_prefix = azurerm_network_interface.bastion-dmz.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-ipsecvpn" {
  count = var.vpn_type == "ipsec" ? 1 : 0 

  name = "${var.vpc_name}-bastion-ipsecvpn"

  network_security_group_name = azurerm_network_security_group.bastion-dmz.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Allow"
  protocol  = "udp"
  priority  = "503"
  direction = "Inbound"
  
  source_port_range     = "*"
  source_address_prefix = "0.0.0.0/0"

  destination_port_ranges    = ["500", "4500"]
  destination_address_prefix = azurerm_network_interface.bastion-dmz.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-vpntunnel" {
  count = length(var.tunnel_vpn_port_start) > 0 && length(var.tunnel_vpn_port_end) > 0 ? 1 : 0 

  name = "${var.vpc_name}-bastion-vpntunnel"

  network_security_group_name = azurerm_network_security_group.bastion-dmz.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Allow"
  protocol  = "*"
  priority  = "504"
  direction = "Inbound"
  
  source_port_range     = "*"
  source_address_prefix = "0.0.0.0/0"

  destination_port_range     = "${var.tunnel_vpn_port_start}-${var.tunnel_vpn_port_end}"
  destination_address_prefix = azurerm_network_interface.bastion-dmz.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-smtp-ext" {
  count = length(var.smtp_relay_host) == 0 ? 0 : 1 

  name = "${var.vpc_name}-bastion-smtp-ext"

  network_security_group_name = azurerm_network_security_group.bastion-dmz.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Allow"
  protocol  = "tcp"
  priority  = "505"
  direction = "Inbound"

  source_port_range     = "*"
  source_address_prefix = "0.0.0.0/0"

  destination_port_range     = "25"
  destination_address_prefix = azurerm_network_interface.bastion-dmz.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-deny-dmz" {
  name = "${var.vpc_name}-bastion-deny-dmz"

  network_security_group_name = azurerm_network_security_group.bastion-dmz.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Deny"
  protocol  = "*"
  priority  = "600"
  direction = "Inbound"

  source_port_range     = "*"
  source_address_prefix = azurerm_subnet.dmz.address_prefix

  destination_port_range     = "*"
  destination_address_prefix = azurerm_network_interface.bastion-dmz.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-smtp-int" {
  count = length(var.smtp_relay_host) == 0 ? 0 : 1 

  name = "${var.vpc_name}-bastion-smtp-int"

  network_security_group_name = azurerm_network_security_group.bastion-admin.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Allow"
  protocol  = "tcp"
  priority  = "500"
  direction = "Inbound"

  source_port_range       = "*"
  source_address_prefixes = [var.vpn_network, var.vpc_cidr]

  destination_port_range     = "2525"
  destination_address_prefix = azurerm_network_interface.bastion-admin.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-proxy" {
  count = length(var.squidproxy_server_port) == 0 ? 0 : 1 

  name = "${var.vpc_name}-bastion-proxy"

  network_security_group_name = azurerm_network_security_group.bastion-admin.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Allow"
  protocol  = "tcp"
  priority  = "501"
  direction = "Inbound"

  source_port_range       = "*"
  source_address_prefixes = [var.vpn_network, var.vpc_cidr]

  destination_port_range     = var.squidproxy_server_port
  destination_address_prefix = azurerm_network_interface.bastion-admin.ip_configuration.0.private_ip_address
}

resource "azurerm_network_security_rule" "bastion-deny-vpc" {
  name = "${var.vpc_name}-bastion-deny-vpc"

  network_security_group_name = azurerm_network_security_group.bastion-admin.name
  resource_group_name         = azurerm_resource_group.bootstrap.name

  access    = "Deny"
  protocol  = "*"
  priority  = "600"
  direction = "Inbound"

  source_port_range     = "*"
  source_address_prefix = var.vpc_cidr

  destination_port_range     = "*"
  destination_address_prefix = azurerm_network_interface.bastion-admin.ip_configuration.0.private_ip_address
}
