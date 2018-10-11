#!/bin/bash

LOG_DIR=$(pwd)
BUILD_DIR=$(cd $(dirname $BASH_SOURCE)/.. && pwd)

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

set -euo pipefail

function gcp::build_image() {

    local image_name=$1
    local source_image_family=$2
    local packer_manifest=$3

    echo -e "\nDeleting image with name '$image_name'..."

    set +e
    gcloud compute images list --filter="name=$image_name" | grep "$image_name" >/dev/null 2>&1
    [[ $? -eq 0 ]] && gcloud compute images delete -q "$image_name"
    set -e

    echo -e "\nBuilding image '$IMAGE_NAME' using source image family '$SOURCE_IMAGE_FAMILY'..."
    cd $(dirname $packer_manifest)
    packer build \
        -var "build_dir=$BUILD_DIR" \
        -var "source_image_family=$SOURCE_IMAGE_FAMILY" \
        -var "image_name=$IMAGE_NAME" \
        $(basename $packer_manifest)
    cd -
}

gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS

echo "Building image."
gcp::build_image "$IMAGE_NAME" \
    "$SOURCE_IMAGE_FAMILY" "$BUILD_DIR/packer/build-gcp.json" 2>&1 \
    | tee $LOG_DIR/build-gcp.log
