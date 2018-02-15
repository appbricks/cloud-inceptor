# Packer configuration to build an bastion or inception VM for cloud deployment automation.

It installs the following packages to an Ubuntu cloud image.

* OpenVPN
* SquidProxy
* Docker
* Concourse

Each of the above tools will be configured on first boot. 

## Building

The images are built using [packer](http://packer.io/): 

* To build an AWS AMI

  ```
  $ ./build-aws-image.sh us-west-1
  ```

  > If region is not provided an AMI will be built for each region.

## Configuring Services

Packages are configured by placing a YAML file named `config.yml` within the root users home folder with the configuration parameters for the respective package. If packages have not been configured by explicitly calling the `<ROOT USER HOME>/bin/configure_*` script they will configured on boot if `config.yml` is present and the package configuration variables are provided.

The `config.yml` configuration may be passed during instance creation using one of the following methods.

1. As user data user data for IaaS's that support retrieval via an AWS compatible "metadata" service.
2. As a file that is created at `<ROOT USER HOME>/config.yml` via a cloud-init configuration.

The base configuration values are:

```
---
server:
  host: <PUBLIC IP OR DNS NAME - can also be an Elastic or Floating IP>
  ip: <IP OF INTERFACE FOR EXTERNAL INGRESS TRAFFIC - if empty host IP is assumed to be IP on the interface>
  lan_interfaces: <COMMA SEPARATED LIST OF 'interface|ip|netmask|route_cidr|route_netmask|gateway|'>
```

The `server.host` configuration value should be the externally accessible IP of the inception instance. The server network interface configuration should be provided as a comma separated list of `interface|ip|netmask|route_cidr|route_netmask|`. 

* `interface` - the name of the interface
* `ip` - the IP of the interface on the attached subnet.
* `netmask` - the netmask of the subnet this interface is attached to
* `route_cidr` - the LAN network CIDR range that should be routed via this interface. 
* `route_netmask` - the LAN netmask of the network that should be routed via this interface. If this is not provided then the `netmask` will be assumed as the route netmask.
* `gateway` - the gateway for the route

If the `ip` is empty then it will be assumed that the NIC is auto configured and this configuration will only be used when configuring OpenVPN. It is important that the first interface is the external interface via which VPN connections will be made.

### OpenVPN

OpenVPN is configured via the `bin\install_openvpn` script. It will execute if the `port` configuration value is present.

```
openvpn:
  port: <THE PORT OPENVPN WILL LISTEN ON>
  protocol: [tcp|udp]
  subnet: <VPN SUBNET i.e. 192.168.111.0/24>
  netmask: <VPN SUBNET NETMASK i.e. 255.255.255.0>
  admin_passwd: <VPN ADMIN PASSWORD>
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

> Providing the `admin_passwd` creates a "vpn_admin" user with VPN credentials and disables the default os user.

> For the VPN certificate, fields `country`,`org`,`cn`,`ou`,`email` and name are mandatory.

If you are deploying to AWS manually and would like to provide the `config.yml` as user data, then pre-allocate an elastic IP and associate it with the instance once it has launched. An example config.yml would be:

```
---
server:
  host: <Your Elastic IP>
  lan_interfaces: 'eth0|172.31.0.0/16|255.255.0.0|172.31.0.254'

openvpn:
  port: 1194
  protocol: udp
  subnet: 192.168.111.0/24
  netmask: 255.255.255.0
  ssh_passwd: 1234
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

Concourse is configured via the `bin\install_concourse` script. As with the other scripts it will execute only if the `port` configuration value is present. It is recommended to configure Concourse to listen on port 127.0.0.1 and access concourse via a tunnel or VPN for security reasons, especially if you plan to use Concourse to automate infrastructure and software configuration.

```
concourse:
  port: <IP:PORT TO LISTEN ON - if IP is not provided concourse will listen on all interfaces>
  password: <PASSWORD FOR BASIC AUTH TO DEFAULT TEAM>
  pipeline-repo: <GIT REPO - repo containing the initial set of pipelines>
  pipeline-repo-branch: <GIT REPO BRANCH - (optional) branch of repo containing the initial set of pipelines>
  pipeline-repo-tag-filter: <GIT REPO TAG FILTER - (optional) tag to match when retrieving latest pipelines>
  pipeline-folder: <PIPELINE FOLDER - folder container pipeline configurations>
  pipeline-var-folder: <PIPELINE VARIABLE FOLDER - folder containing pipeline variables>
  environment-key: <ENVIRONMENT KEY - key identifying pipeline environment>
```

Although not required, the pipeline repo variables should be encrypted using [git-crypt](https://github.com/AGWA/git-crypt). GPG encrypted repos may be unencrypted using one of the following methods.

1. Upload the GPG public key of the user to use for decryption as `<ROOT USER HOME>/git-crypt-user.pem`.

  Export your GPG as follows and base64 encode it. 

  ```
  gpg --export-secret-key -a msamaratunga@appbricks.net | base64
  ```

  Copy the output as the content for the cloud-config configuration file saved to `<ROOT USER HOME>/git-crypt-user.pem` as follows.

  ```
  #cloud-config

  write_files:
    content: !!binary |
      <BASE64 encoded key file>
    path: /root/git-crypt-user.pem
    permissions: '0600'
  ```

2. Upload a symmetric key for decryption as `<ROOT USER HOME>/git-crypt-key.pem`. As above the exported key needs to be base64 encoded and passed as file content in the cloud-config configuration file.

The `environment-key` may be used to pick a folder within the `pipeline-var-folder` containing the environment specific variables. If it is not provided then the `params.yml` file at the root of the `pipeline-var-folder` will be selected to interpolate the pipeline the configuration.

The Concourse configuration will setup a bootstrap pipeline that create pipelines using pipeline definitions found in `pipeline-repo-branch\pipeline-folder`. You should use the `pipeline-repo` to setup pipelines that install, upgrade and operate the system that you wish to build.
