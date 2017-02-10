#!/bin/bash

printf "\n\n\n\n"
sleep 1

echo "Building Azure image with Packer..."
sleep 1
printf "\n"

packer build ubuntu-14.04-amd64.json

echo "Image ready!"

printf "\n\n\n\n"
sleep 1

echo "Provisioning Azure environment with Terraform..."
sleep 1
printf "\n"

terraform apply  
echo "Environment ready!"
