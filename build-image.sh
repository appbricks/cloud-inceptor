#!/bin/bash

if [[ $1 == aws ]]; then

    packer build \
        -var 'region=us-west-1' \
        -var 'ami=ami-bf3ec1fb' \
        bastion.json

    packer build \
        -var 'region=us-west-2' \
        -var 'ami=ami-93868ea3' \
        bastion.json

    packer build \
        -var 'region=us-east-1' \
        -var 'ami=ami-478b262c' \
        bastion.json
fi
