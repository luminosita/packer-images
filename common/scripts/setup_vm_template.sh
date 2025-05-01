#!/bin/bash

set -e

DIR="$(dirname "$0")"
LOG_FILE="$DIR/logs/template_creation_$(date +'%Y%m%d_%H%M%S').log"

function usage {
	# Display Help
	echo "Install script for Proxmox VM Template"
	echo
	echo "Syntax: $script_name create|destroy [-i|c]"
	echo "Create options:"
	echo "  -i     VM ID."
    echo "  -c     Config file path."
	echo "Destroy options:"
	echo "  -i     VM ID."
	echo

    exit 1
}

# Function to log messages
log() {
  local timestamp=$(date +'[%Y-%m-%d %H:%M:%S]')
  echo "$timestamp $1" | tee -a "$LOG_FILE"
}

function qm_create_vm {
   #UEFI BOOT 
    qm create ${vm_id} \
        --name ${vm_name} \
        --net0 virtio,bridge=vmbr0,queues=4 \
        --bootdisk scsi0 \
        --ostype l26 \
        --balloon 256 \
        --memory 512 \
        --onboot no \
        --sockets 1 \
        --cores 1
}

function qm_import_disk {
    qemu-img resize ${image_file} +4G

    qm disk import ${vm_id} ${image_file} ${vm_storage}
}
  
function qm_set_options {
    qm set ${vm_id} \
        --scsihw virtio-scsi-single \
        --scsi0 ${vm_storage}:vm-${vm_id}-disk-0,discard=on,iothread=1,ssd=1 \
        --boot order=scsi0 \
        --serial0 socket --vga serial0 \
        --ipconfig0 ip=dhcp \
        --agent 1 \
        --ide2 ${vm_storage}:cloudinit \
 	    --cicustom "user=local:snippets/$ci_userdata_file" \
        --citype nocloud
}  

function apply_patches {
    cat ${ci_userdata_path} | ./go/bin/yaml_patch ${patches_file} | tee ${ci_userdata_patched_path}
}

function create_patches_file {
    patches_file="tmp/patches.yaml"

    create_patches_file

    cat $config_file | yq '.cloud_init.patches' | tee $patches_file
}

function create {
    log "Downloading Cloud-init config ($ci_base)"
    log "----------------------------------------"
    sleep 2

    wget -O ${ci_userdata_path} ${ci_userdata_url}

    apply_patches

    log "Downloading $image_name Cloud image ($image_version)"
    log "----------------------------------------"
    sleep 2

    wget -O ${image_file} ${image_url}

    log "Starting template creation"
    log "----------------------------------------"
    sleep 2

    qm_create_vm 

    log "VM created (ID: $id, Name: $vm_name, Storage: $storage)"
    log "----------------------------------------"
    sleep 2

    qm_import_disk 

    log "QCow2 disk imported"
    log "----------------------------------------"
    sleep 2

    qm_set_options 

    log "Waiting for cloud-init drive to be ready..."
    sleep 5

    log "Converting to template..."
    qm template $id

    log "Template $vm_name (ID: $id) created on node \"$HOSTNAME\""
    log "----------------------------------------"

    rm -f ${image_file}
}

function destroy {
    qm destroy $id

    rm -f $ci_userdata_path
}

if [ -z "$1" ]; then usage; fi

command=$1

shift 1

while getopts ":i:c:" o; do
    case "${o}" in
        i)
            vm_id=${OPTARG}
            # ((s == 45 || s == 90)) || usage
            ;;
        c)
            config_file=${OPTARG}
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

mkdir -p logs
mkdir -p tmp

vm_name=$(cat $config_file | yq '.vm.name')
vm_storage=$(cat $config_file | yq '.vm.storage')

image_name=$(cat $config_file | yq '.image.name')
image_version=$(cat $config_file | yq '.image.version')
image_url=$(cat $config_file | yq '.image.url')
image_file="tmp/$(basename ${image_url})"

ci_base=$(cat $config_file | yq '.cloud_init.base')

ci_userdata_file="$vm_id-cloudinit.yaml"
ci_userdata_path="/var/lib/vz/snippets/$ci_userdata_file"
ci_userdata_patched_path="/var/lib/vz/snippets/$ci_userdata_file-patched"
ci_userdata_url="https://github.com/luminosita/packer-snapshots/raw/refs/heads/main/config/cloudinit/$ci_base"

if [ $command == "create" ]; then
    create
elif [ $command == "destroy" ]; then
    destroy
else
    usage
fi

rm -rf tmp