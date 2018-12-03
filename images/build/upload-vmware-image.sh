#!/bin/bash

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

set -euo pipefail

log_dir=$(pwd)
build_dir=$(cd $(dirname $BASH_SOURCE)/.. && pwd)
build_output_dir=$build_dir/.build

type=${1:-inceptor}
image_name="appbricks-$type"

# URL Encode the vCenter username and password
vc_username=$(echo "$VMW_VCENTER_USERNAME" \
  | python -c "import urllib.parse, sys; print(urllib.parse.quote_plus(sys.stdin.read().rstrip()))")
vc_password=$(echo "$VMW_VCENTER_PASSWORD" \
  | python -c "import urllib.parse, sys; print(urllib.parse.quote_plus(sys.stdin.read().rstrip()))")

echo -e "OVA saved as $build_dir/images/$image_name.ova."
echo -e "Running: \n\novftool \\
  --X:logToConsole \\
  --X:logLevel=verbose \\
  --allowExtraConfig \\
  --noSSLVerify \\
  --name=$image_name \\
  --vmFolder=$VMW_VCENTER_TEMPLATES_FOLDER \\
  --net:\"Ethernet 1=$VMW_VCENTER_NETWORK\" \\
  --datastore=$VMW_VCENTER_DATASTORE \\
  --diskMode=thin \\
  $build_output_dir/images/${image_name}-*.ova \\
  vi://$vc_username:$vc_password@$VMW_VCENTER_HOST/$VMW_VCENTER_DATACENTER/host/$VMW_VCENTER_CLUSTER"

set +e
govc vm.destroy "/$VMW_VCENTER_DATACENTER/vm/Discovered virtual machine/$image_name" > /dev/null 2>&1
govc vm.destroy "/$VMW_VCENTER_DATACENTER/vm/$VMW_VCENTER_TEMPLATES_FOLDER/$image_name" > /dev/null 2>&1
set -e

ovftool \
  --X:logToConsole \
  --X:logLevel=verbose \
  --allowExtraConfig \
  --noSSLVerify \
  --name=$image_name \
  --vmFolder=$VMW_VCENTER_TEMPLATES_FOLDER \
  --net:"VM Network=$VMW_VCENTER_NETWORK" \
  --datastore=$VMW_VCENTER_DATASTORE \
  --diskMode=thin \
  $build_output_dir/images/${image_name}-*.ova \
  vi://$vc_username:$vc_password@$VMW_VCENTER_HOST/$VMW_VCENTER_DATACENTER/host/$VMW_VCENTER_CLUSTER 2>&1 \
  | tee $log_dir/upload-vmware-$type.log

govc vm.markastemplate -vm.ipath="/$VMW_VCENTER_DATACENTER/vm/$VMW_VCENTER_TEMPLATES_FOLDER/$image_name"
