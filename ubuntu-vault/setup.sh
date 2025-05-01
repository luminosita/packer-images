#!/bin/bash

set -e

DIR="$(dirname "$0")"

function usage {
	# Display Help
	echo "Install script for Proxmox Ubuntu Vault Template"
	echo
	echo "Syntax: $script_name create|destroy [-i|n|s]"
	echo "Create options:"
	echo "  -i     VM ID."
    echo "  -n     VM Name; optional; default: ubuntu-vault."
    echo "  -s     Storage; optional; default: local-lvm."
	echo "Destroy options: none"
	echo "ENV vars: "
	echo "  UBUNTU_VERSION          Ubuntu version to be installed."
	echo "  ALPINE_VERSION          Alpine version to be installed."
	echo

    exit 1
}

function apply_cloud_init_patch {
    sshkey=$(cat ${ssh_key_path})
    randomStr=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)

    #Replace SSHKEY placeholder in cloud-init user data yaml file
    sed -i 's|SSHKEY|'"$sshkey"'|' $CI_USERDATA_PATH
    sed -i 's|RANDOMPASSWD|'"$randomStr"'|' $CI_USERDATA_PATH
    sed -i 's|VAULT_VERSION|'"$vault_version"'|' $CI_USERDATA_PATH
}

ubuntu_version=${UBUNTU_VERSION:-"25.04"}
vault_version=${VAULT_VERSION:-"1.19.2"}

ssh_key_path="$DIR/gianni_rsa.pub"

DEFAULT_NAME="ubuntu-vault"
NAME_SUFFIX=${vault_version}

CLOUD_IMAGE_NAME="Ubuntu"
CLOUD_IMAGE_VERSION=$ubuntu_version

IMAGE=ubuntu-${ubuntu_version}-server-cloudimg-amd64.img
IMAGE_URL=https://cloud-images.ubuntu.com/releases/oracular/release/${IMAGE}

CI_USERDATA_FILE=ubuntu-vault.yaml

. "$DIR/../common/scripts/vm_template.sh"
