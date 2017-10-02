# Packer project to build an Inception VM for cloud deployment automation.

## Overview

This project will build an inception VM image with tools for securing a virtual private cloud environment and running automation tasks within it.

It installs the following packages.

* OpenVPN
* SquidProxy
* Docker
* Concourse

## Building

* Build an image using [packer](http://packer.io/): 

```
$ build.sh [aws|openstack|vsphere]
```

## Configuring Services

Packages are configured by placing a YAML file named `config.yml` with the configuration parameters for the respective package within the root users home folder. If packages have not be installed by explicitely calling the `<ROOT USER HOME>/bin/install_*` script the install will run on boot if `config.yml` is present and the package configuration is available.

The following configuration value must be provided by default.

```
---
server:
  host: #.#.#.#
```

### OpenVPN

OpenVPN is configured via the `bin\install_openvpn` script. It will execute if the `port` configuration value is present.

```
openvpn:
  port: <THE PORT OPENVPN WILL LISTEN ON>
  protocol: [tcp|udp]
  subnet: <VPN SUBNET i.e. 192.168.111.0/24>
  netmask: <VPN SUBNET NETMASK i.e. 255.255.255.0>
  ssh_passwd: <SSH PASSWORD FOR THE 'ubuntu' USER>
  lan_interfaces: <COMMA SEPARATED LIST OF 'interface|cidr|netmask'>
  dns_servers: <COMMA SEPARATE LIST OF DNS SERVERS TO CONFIGURE ON THE VPN CLIENTS>
  server_domain: <DOMAIN TO USE WHEN CREATING THE VPN KEYS>
  server_organization: <ORGANIZATION TO USE WHEN CREATING THE VPN KEYS>
  server_description: <DESCRIPTION TO USE WHEN CREATING THE VPN KEYS>
  tunnel_all_traffic: [yes|no]
```

### SquidProxy

SquidProxy is configured via the `bin\install_squidproxy` script. It will execute if the `port` configuration value is present.

```
squidproxy:
  port: <INTERFACE IP AND PORT TO LISTEN ON i.e. 0.0.0.0:8888>
  networks: <COMMA SEPARATED CIDR OF SUBNETS THAT THE PROXY WILL ACCEPT CONNECTIONS FROM>
  custom_headers_allowed: <COMMA SEPARATED LIST OF CUSTOM HEADERS THAT WILL BE PASSED THROUGH>
```

### Concourse

```
```
