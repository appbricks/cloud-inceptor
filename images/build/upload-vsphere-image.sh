#!/bin/bash

log_dir=$(pwd)
build_dir=$(cd $(dirname $BASH_SOURCE)/.. && pwd)
build_output_dir=$build_dir/.build

type=${1:-inceptor}
image_name="appbricks-$type"

which govc >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    "ERROR! The GOVC CLI has not been installed. You can download it from https://github.com/vmware/govmomi/."
    exit 1
fi

set -euo pipefail

image_build=$(basename $(ls $build_output_dir/images/${image_name}-*.ova))
build_vmname=${image_build%.*}

set +e
govc vm.destroy "/$VCENTER_DATACENTER/vm/Discovered virtual machine/$build_vmname" >/dev/null 2>&1
govc vm.destroy "/$VCENTER_DATACENTER/vm/$VCENTER_TEMPLATES_FOLDER/$image_name" >/dev/null 2>&1
govc folder.create "/$VCENTER_DATACENTER/vm/$VCENTER_TEMPLATES_FOLDER" >/dev/null 2>&1
set -e

govc import.spec \
  $build_output_dir/images/${image_name}-*.ova \
  | jq \
	--arg image_name "$image_name" \
	--arg network "$VCENTER_NETWORK" \
	'del(.Deployment)
	| .Name = $image_name
	| .DiskProvisioning = "thin"
	| .NetworkMapping[].Network = $network
	| .PowerOn = false
	| .MarkAsTemplate = true' \
  > $build_output_dir/images/${image_name}.json

govc import.ova \
  -dc=$VCENTER_DATACENTER \
  -ds=$VCENTER_DATASTORE \
  -folder=/$VCENTER_DATACENTER/vm/$VCENTER_TEMPLATES_FOLDER \
  -options=$build_output_dir/images/${image_name}.json \
  $build_output_dir/images/${image_name}-*.ova  
