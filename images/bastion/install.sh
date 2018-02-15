#!/bin/bash

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then
    echo -e "\nUsage: ./install.sh [SSH KEY PATH] [SSH_USER] [HOST IP]\n"
    exit 1
fi

ssh_key=$1
ssh_user=$2
ssh_host=$2@$3
host_ip=$3

function s() {
    /usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $ssh_key $@ 
}

function sc() {
    /usr/bin/scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $ssh_key $@
}

function sync() {
    rsync -avz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $ssh_key" --progress $@
}

s $ssh_host "mkdir -p /tmp/install-scripts"
sync ./* $ssh_host:/tmp/install-scripts

# **** BEGIN INSTALL ****

s $ssh_host << EOF
sudo -s -- << INSTALL

rm -fr /root/.bin
mkdir -p /root/.bin

mv -f /tmp/install-scripts/bin/rc.local /etc/rc.local
chmod 0755 /etc/rc.local

cp -fr /tmp/install-scripts/bin/* /root/.bin

if [[ "$4" == "install" ]]; then
    cd /root
    /root/.bin/install_common
    /root/.bin/configure_openvpn
    /root/.bin/configure_squidproxy
    /root/.bin/configure_concourse
fi
INSTALL

rm -fr /tmp/install-scripts
sudo reboot

EOF

# **** END INSTALL ****