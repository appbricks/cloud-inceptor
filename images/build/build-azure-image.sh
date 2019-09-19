#!/bin/bash

LOG_DIR=$(pwd)
BUILD_DIR=$(cd $(dirname $BASH_SOURCE)/.. && pwd)

IMAGE_NAME="appbricks-inceptor-bastion"

SOURCE_IMAGE_PUBLISHER="Canonical"
SOURCE_IMAGE_TYPE="UbuntuServer"
SOURCE_IMAGE_VERSION="18.04-LTS"

ARM_DEFAULT_RESOURCE_GROUP=${ARM_DEFAULT_RESOURCE_GROUP:-default}
echo "Building image in resource group '$ARM_DEFAULT_RESOURCE_GROUP'."

which az >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    "ERROR! The Azure SDK CLI needs to be installed and configured. (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)"
    exit 1
fi

if [[ -z $ARM_SUBSCRIPTION_ID
  || -z $ARM_TENANT_ID
  || -z $ARM_CLIENT_ID
  || -z $ARM_CLIENT_SECRET ]]; then
    "ERROR! Azure environment variables ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID and ARM_CLIENT_SECRET should be set."
    exit 1
fi

set -euo pipefail
az login --service-principal \
  --username "$ARM_CLIENT_ID" \
  --password "$ARM_CLIENT_SECRET" \
  --tenant "$ARM_TENANT_ID"

echo "Logged into Azure..."

location=$(az group show --name $ARM_DEFAULT_RESOURCE_GROUP | jq -r .location)
image_publisher=$SOURCE_IMAGE_PUBLISHER
image_offer=$SOURCE_IMAGE_TYPE
image_sku=$SOURCE_IMAGE_VERSION
image_version=$(az vm image list --all \
  --publisher "$image_publisher" \
  --offer "$image_offer" \
  --sku "$image_sku" \
  | jq -r 'sort_by(.version) | reverse | first | .version')

# Accept terms if any
az vm image accept-terms --urn "$image_publisher:$image_offer:$image_sku:$image_version"

function azure::build_image() {

    local location=$1
    local packer_manifest=$2

    echo -e "\nDeleting image with name '$IMAGE_NAME'."

    set +e
    resp=$(az image show --name "$IMAGE_NAME" --resource-group "$ARM_DEFAULT_RESOURCE_GROUP" 2>/dev/null) 
    [[ $? -eq 0 ]] && az image delete --ids $(echo "$resp" | jq -r .id)
    set -e

    echo -e "\nBuilding image '$IMAGE_NAME' using source image type '$SOURCE_IMAGE_TYPE' from publisher '$SOURCE_IMAGE_PUBLISHER'"
    echo -e "and saving to resource group '$ARM_DEFAULT_RESOURCE_GROUP' in '$location'...\n"
    cd $(dirname $packer_manifest)
    packer build \
        -var "build_dir=$BUILD_DIR" \
        -var "image_name=$IMAGE_NAME" \
        -var "resource_group=$ARM_DEFAULT_RESOURCE_GROUP" \
        -var "location=$location" \
        -var "image_publisher=$image_publisher" \
        -var "image_offer=$image_offer" \
        -var "image_sku=$image_sku" \
        -var "image_version=$image_version" \
        $(basename $packer_manifest)
    cd -
}

echo "Building image."
azure::build_image "$location" \
  "$BUILD_DIR/packer/build-azure.json" 2>&1 \
  | tee $LOG_DIR/build-azure.log
