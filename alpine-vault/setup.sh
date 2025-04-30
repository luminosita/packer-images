#!/bin/bash

set -e

function usage {
	# Display Help
	echo "Install script for Vault Cluster"
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


# Log file
LOG_FILE="logs/template_creation_$(date +'%Y%m%d_%H%M%S').log"
SSH_KEY_PATH="./gianni_rsa.pub"
USER="vault"

# Function to log messages
log() {
  local timestamp=$(date +'[%Y-%m-%d %H:%M:%S]')
  echo "$timestamp $1" | tee -a "$LOG_FILE"
}

mkdir -p logs

if [ -z "$1" ]; then usage; fi

command=$1

shift 1

while getopts ":i:n:s:" o; do
    case "${o}" in
        i)
            id=${OPTARG}
            # ((s == 45 || s == 90)) || usage
            ;;
        n)
            name=${OPTARG}
            ;;
        s)
            storage=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${id}" ]; then
    usage
fi

if [ $command == "create" ]; then
    alpine_version=${ALPINE_VERSION:-"3.21.2"}
    vault_version=${VAULT_VERSION:-"1.19.2"}
    name=${name:-"alpine-vault"}
    vm_name="$name-$vault_version"
    storage=${storage:-"local-lvm"}

    major_version=$(echo $alpine_version | sed -nr 's/([^0-9]*)([0-9]+)\.([0-9]+)\.([0-9]+).*/\2\.\3/p')

    log "Downloading Alpine Cloud image ($alpine_version)"
    log "----------------------------------------"
    sleep 2

    image=nocloud_alpine-${alpine_version}-x86_64-bios-cloudinit-r0.qcow2
#    image=ubuntu-${ubuntu_version}-server-cloudimg-amd64.img

    wget https://dl-cdn.alpinelinux.org/alpine/v${major_version}/releases/cloud/${image}
#    wget https://cloud-images.ubuntu.com/releases/oracular/release/ubuntu-${ubuntu_version}-server-cloudimg-amd64.img

    log "Downloading Cloud-init (vault-$vault_version)"
    log "----------------------------------------"
    sleep 2

    ci_userdata=/var/lib/vz/snippets/alpine-vault.yaml
    sshkey=$(cat ${SSH_KEY_PATH})
    randomStr=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)

    wget -O $ci_userdata https://github.com/luminosita/packer-snapshots/raw/refs/heads/main/config/cloudinit/alpine-vault.yaml
    
    #Replace SSHKEY placeholder in cloud-init user data yaml file
    sed -i 's|SSHKEY|'"$sshkey"'|' $ci_userdata
    sed -i 's|PASSWD|'"$randomStr"'|' $ci_userdata
    sed -i 's|VAULT_VERSION|'"$vault_version"'|' $ci_userdata

    log "Starting template creation"
    log "----------------------------------------"
    sleep 2

    #UEFI BOOT
    qm create $id \
        --name $vm_name \
        --net0 virtio,bridge=vmbr0,queues=4 \
        --bootdisk scsi0 \
        --ostype l26 \
        --balloon 256 \
        --memory 512 \
        --onboot no \
        --sockets 1 \
        --cores 1

    log "VM created (ID: $id, Name: $vm_name, Storage: $storage)"
    log "----------------------------------------"
    sleep 2

    qemu-img resize ${image} +4G

    qm disk import $id ${image} $storage

    log "QCow2 disk imported"
    log "----------------------------------------"
    sleep 2

    qm set $id \
        --scsihw virtio-scsi-single \
        --scsi0 $storage:vm-$id-disk-0,discard=on,iothread=1,ssd=1 \
        --boot order=scsi0 \
        --serial0 socket --vga serial0 \
        --ipconfig0 ip=dhcp \
        --agent 1 \
        --ide2 $storage:cloudinit \
 	    --cicustom "user=local:snippets/vault-${vault_version}.yaml" \
        --citype nocloud

    log "Waiting for cloud-init drive to be ready..."
    sleep 5

    log "Converting to template..."
    qm template $id

    log "Template $vm_name (ID: $id) created on node \"$HOSTNAME\""
    log "----------------------------------------"

    rm -f ${image}
elif [ $command == "destroy" ]; then
    qm destroy $id
else
    usage
fi