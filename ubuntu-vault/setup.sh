#!/bin/bash

set -e

dir="$(dirname "$0")"

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

function setup_cloud_init {
    sshkey=$(cat ${SSH_KEY_PATH})
    randomStr=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)

    log "Downloading Cloud-init (ubuntu-vault)"
    log "----------------------------------------"
    sleep 2

    wget -O $ci_userdata_path https://github.com/luminosita/packer-snapshots/raw/refs/heads/main/config/cloudinit/${ci_userdata_file}

    #Replace SSHKEY placeholder in cloud-init user data yaml file
    sed -i 's|SSHKEY|'"$sshkey"'|' $ci_userdata_path
    sed -i 's|RANDOMPASSWD|'"$randomStr"'|' $ci_userdata_path
    sed -i 's|VAULT_VERSION|'"$vault_version"'|' $ci_userdata_path
}

USER="ubuntu"

ubuntu_version=${UBUNTU_VERSION:-"25.04"}
vault_version=${VAULT_VERSION:-"1.19.2"}
name=${name:-"ubuntu-vault"}
vm_name="$name-$vault_version"

CLOUD_IMAGE_NAME="Ubuntu"
CLOUD_IMAGE_VERSION=$ubuntu_version

image=ubuntu-${ubuntu_version}-server-cloudimg-amd64.img

imageUrl=https://cloud-images.ubuntu.com/releases/${ubuntu_version}/release/${image}

ci_userdata_file=ubuntu-vault.yaml
ci_userdata_path=/var/lib/vz/snippets/${ci_userdata_file}

. "$dir/../common/scripts/vm_template.sh"