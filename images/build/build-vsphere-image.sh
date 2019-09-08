#!/bin/bash -u

log_dir=$(pwd)
build_dir=$(cd $(dirname $BASH_SOURCE)/.. && pwd)
build_output_dir=$build_dir/.build

type=${1:-inceptor}
image_name="appbricks-$type"

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

  $build_dir/build/ssh_pass "$ESX_PASSWORD" "$ESX_USERNAME@$ESX_HOST" '
    set -x
    esxcli system settings advanced set -o /Net/GuestIPHack -i 1
    esxcli network firewall ruleset set --ruleset-id gdbserver --enabled true' \
  >$log_dir/build-vsphere-$type.log
else

  echo -e "\nUpdating ESX Host for build. Please enter '$ESX_USERNAME' password if prompted.."
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $ESX_USERNAME@$ESX_HOST '
    set -x
    esxcli system settings advanced set -o /Net/GuestIPHack -i 1
    esxcli network firewall ruleset set --ruleset-id gdbserver --enabled true' \
  >$log_dir/build-vsphere-$type.log
fi

set -eo pipefail

rm -f $build_output_dir/images/${image_name}-*.ova

iso_url="http://releases.ubuntu.com/18.04/ubuntu-18.04.2-live-server-amd64.iso"
iso_checksum="ea6ccb5b57813908c006f42f7ac8eaa4fc603883a2d07876cf9ed74610ba2f5"
iso_checksum_type="sha256"
boot_command_prefix="<enter><wait><f6><esc><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>"

cd $build_dir/packer

packer build \
  -var "build_dir=$build_dir" \
  -var "iso_url=$iso_url" \
  -var "iso_checksum=$iso_checksum" \
  -var "iso_checksum_type=$iso_checksum_type" \
  -var "boot_command_prefix=$boot_command_prefix" \
  -var "vm_name=$image_name" \
  build-vsphere-$type.json 2>&1 \
  | tee -a $log_dir/build-vsphere-$type.log

cd -
