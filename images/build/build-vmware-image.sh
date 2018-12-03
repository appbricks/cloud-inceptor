#!/bin/bash

log_dir=$(pwd)
build_dir=$(cd $(dirname $BASH_SOURCE)/.. && pwd)
build_output_dir=$build_dir/.build

type=${1:-inceptor}
image_name="appbricks-$type"

VMW_BUILD_PRESEED_URL=${VMW_BUILD_PRESEED_URL:-}

which ovftool >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    "ERROR! The VMWare OVFTool has not been installed. You can download it from https://www.vmware.com/support/developer/ovf/."
    exit 1
fi

which govc >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    "ERROR! The GOVC CLI has not been installed. You can download it from https://github.com/vmware/govmomi/."
    exit 1
fi

which expect >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
	esx_host_update="$build_dir/build/ssh_pass '$VMW_ESX_PASSWORD' '$VMW_ESX_USERNAME@$VMW_ESX_HOST'"
else
	esx_host_update="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $VMW_ESX_USERNAME@$VMW_ESX_HOST"
fi

set -euo pipefail

echo -e "\nUpdating ESX Host for build. Please enter '$VMW_ESX_USERNAME' password if prompted.."
$esx_host_update '
	esxcli system settings advanced set -o /Net/GuestIPHack -i 1
	esxcli network firewall ruleset set --ruleset-id gdbserver --enabled true
' >/dev/null 2>&1

rm -f $build_output_dir/images/${image_name}-*.ova

iso_url="http://releases.ubuntu.com/16.04/ubuntu-16.04.5-server-amd64.iso"
iso_checksum="c94de1cc2e10160f325eb54638a5b5aa38f181d60ee33dae9578d96d932ee5f8"
iso_checksum_type="sha256"
boot_command_prefix="<enter><wait><f6><esc><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>"

cd $build_dir/packer

if [[ -n $VMW_BUILD_PRESEED_URL ]]; then

  packer build \
    -var "build_dir=$build_dir" \
    -var "iso_url=$iso_url" \
    -var "iso_checksum=$iso_checksum" \
    -var "iso_checksum_type=$iso_checksum_type" \
    -var "boot_command_prefix=$boot_command_prefix" \
    -var "preseed_url=$VMW_BUILD_PRESEED_URL" \
    -var "vm_name=$image_name" \
    build-vmware-$type.json 2>&1 \
    | tee $log_dir/build-vmware-$type.log
else
  packer build \
    -var "build_dir=$build_dir" \
    -var "iso_url=$iso_url" \
    -var "iso_checksum=$iso_checksum" \
    -var "iso_checksum_type=$iso_checksum_type" \
    -var "boot_command_prefix=$boot_command_prefix" \
    -var "vm_name=$image_name" \
    build-vmware-$type.json 2>&1 \
    | tee $log_dir/build-vmware-$type.log
fi

cd -
