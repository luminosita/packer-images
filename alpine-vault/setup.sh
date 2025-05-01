#!/bin/bash

set -e

DIR="$(dirname "$0")"

function usage {
	# Display Help
	echo "Install script for Proxmox Alpine Vault Template"
	echo
	echo "Syntax: $script_name create|destroy [-i|n|s]"
	echo "Create options:"
	echo "  -i     VM ID."
    echo "  -n     VM Name; optional; default: alpine-vault."
    echo "  -s     Storage; optional; default: local-lvm."
	echo "Destroy options: none"
	echo "ENV vars: "
	echo "  VAULT_VERSION           Vault version to be installed."
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

alpine_version=${ALPINE_VERSION:-"3.21.2"}
major_version=$(echo $alpine_version | sed -nr 's/([^0-9]*)([0-9]+)\.([0-9]+)\.([0-9]+).*/\2\.\3/p')
vault_version=${VAULT_VERSION:-"1.19.2"}

ssh_key_path="$DIR/gianni_rsa.pub"

DEFAULT_NAME="alpine-vault"
NAME_SUFFIX=${vault_version}

CLOUD_IMAGE_NAME="Alpine"
CLOUD_IMAGE_VERSION=$alpine_version

IMAGE=nocloud_alpine-${alpine_version}-x86_64-bios-cloudinit-r0.qcow2
#    image=ubuntu-${ubuntu_version}-server-cloudimg-amd64.img

IMAGE_URL=https://dl-cdn.alpinelinux.org/alpine/v${major_version}/releases/cloud/${image}
# imageUrl=https://cloud-images.ubuntu.com/releases/oracular/release/${image}

CI_USERDATA_FILE=alpine-vault.yaml
CI_USERDATA_PATH=/var/lib/vz/snippets/${CI_USERDATA_FILE}
CI_USERDATA_URL=https://github.com/luminosita/packer-snapshots/raw/refs/heads/main/config/cloudinit/${CI_USERDATA_FILE}

. "$DIR/../common/scripts/vm_template.sh"