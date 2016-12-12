# Packer project to build Bastion VM

## Overview

This project will build a Bastion VM image that can be configured using cloud metadata. 
It can be customized with the following services. 

* OpenVPN
* SquidProxy

You can optionally run an install script on an existing VM.

## Usage

* Build an image using [packer](http://packer.io/): 

```
$ build-image.sh [aws|openstack]
```

* Install on a remote instance via SSH: 

```
$ install.sh [SSH KEY PATH] [SSH_USER] [REMOTE HOST]
```
