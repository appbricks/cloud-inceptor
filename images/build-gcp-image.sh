#!/bin/bash

SOURCE_IMAGE_FAMILY=ubuntu-1604-lts
IMAGE_NAME="appbricks-inceptor-bastion"

which gcloud >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    "ERROR! The Google SDK CLI needs to be installed and configured. (https://cloud.google.com/sdk/)"
    exit 1
fi

if [[ ! -e $GOOGLE_CREDENTIALS ]]; then
    "ERROR! Invalid Google service account key file path in the GOOGLE_CREDENTIALS environment variable"
    exit 1
fi

function gcp::build_image() {

    local image_name=$1
    local source_image_family=$2
    local packer_manifest=$3

    # echo -e "\nDeleting image with name '$image_name'..."
    # gcloud compute images list --filter="name=$image_name" | grep "$image_name" >/dev/null 2>&1
    # [[ $? -eq 0 ]] && gcloud compute images delete -q "$image_name"

    echo -e "\nBuilding image '$IMAGE_NAME' using source image family '$SOURCE_IMAGE_FAMILY'..."
    cd $(dirname $packer_manifest)
    packer build \
        -var "source_image_family=$SOURCE_IMAGE_FAMILY" \
        -var "image_name=$IMAGE_NAME" \
        $(basename $packer_manifest)
    cd -
}

log_dir=${build_log_dir:-./}

echo "Building image."
gcp::build_image "$IMAGE_NAME" \
    "$SOURCE_IMAGE_FAMILY" "bastion/build-gcp.json" 2>&1 \
    | tee $log_dir/build-gcp.log
