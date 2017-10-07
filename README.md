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

  - Build an AWS AMI
    
  ```
  $ ./build-aws-image.sh us-west-1
  ```

  > If region is not provided an AMI will be built for each region.

## Configuring Services

Packages are configured by placing a YAML file named `config.yml` within the root users home folder with the configuration parameters for the respective package. If packages have not be configured by explicitely calling the `<ROOT USER HOME>/bin/configure_*` script they will configured on boot if `config.yml` is present and the package configuration is available.

The following configuration value should be the externally accessible IP of the inception instance.

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
  server_domain: <VPN SERVER DOMAIN>
  tunnel_all_traffic: [yes|no]
  vpn_cert:
    name: <IDENTIFYING NAME>
    org: <COMPANY NAME>
    email: <ADMIN EMAIL>
    city: <CITY>
    province: <STATE/PROVINCE>
    country: <ISO COUNTRY CODE>
    ou: <ORGANIZATION UNIT>
    cn: <COMMON NAME for VPN server>
  users: <COMMA SEPARATED LIST OF 'user|passwd'>
```

> For the cert fields `country`,`org`,`cn`,`ou`,`email` and name are mandatory.

If you are deploying to AWS and would like to provide the `config.yml` as user data, then pre-allocate an elastic IP and associate it with the instance once it has launched. An example config.yml would be:

```
---
server:
  host: <Your Elastic IP>

openvpn:
  port: 1194
  protocol: udp
  subnet: 192.168.111.0/24
  netmask: 255.255.255.0
  ssh_passwd: 1234
  lan_interfaces: 'eth0|172.31.0.0/16|255.255.0.0'
  dns_servers: '8.8.8.8'
  server_domain: acme.io
  server_description: Acme-VPN
  tunnel_all_traffic: yes
  vpn_cert:
    name: acme-vpn
    org: Acme, Inc.
    email: admin@acme.org
    city: New York
    province: NY
    country: UD
    ou: Dev
    cn: acme.org
  users: 'user1|passw0rd1,user2|passw0rd2'

squidproxy:
  port: 0.0.0.0:8888
  networks: '172.31.0.0/16'
  custom_headers_allowed: 'X-Auth-Token'
```

You can also configure OpenVPN after the instance has been launched by creating the `config.yml` under the root home directory and rebooting the instance. Additional users can be added by running the following script.

```
create_vpn_user <USER> <PASSWORD>
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
