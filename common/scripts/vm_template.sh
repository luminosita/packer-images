#!/bin/bash

# Log file
LOG_FILE="$DIR/logs/template_creation_$(date +'%Y%m%d_%H%M%S').log"

# Function to log messages
log() {
  local timestamp=$(date +'[%Y-%m-%d %H:%M:%S]')
  echo "$timestamp $1" | tee -a "$LOG_FILE"
}

function qm_create_vm {
   #UEFI BOOT 
    qm create ${id} \
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
    qemu-img resize ${IMAGE} +4G

    qm disk import ${id} ${IMAGE} ${storage}
}
  
function qm_set_options {
    qm set ${id} \
        --scsihw virtio-scsi-single \
        --scsi0 ${storage}:vm-${id}-disk-0,discard=on,iothread=1,ssd=1 \
        --boot order=scsi0 \
        --serial0 socket --vga serial0 \
        --ipconfig0 ip=dhcp \
        --agent 1 \
        --ide2 ${storage}:cloudinit \
 	    --cicustom "user=local:snippets/$CI_USERDATA_FILE" \
        --citype nocloud
}  

function create {
    storage=${storage:-"local-lvm"}

    log "Downloading Cloud-init config ($CI_USERDATA_FILE)"
    log "----------------------------------------"
    sleep 2

    wget -O $ci_userdata_path $ci_userdata_url

    apply_cloud_init_patch $ci_userdata_path

    log "Downloading $CLOUD_IMAGE_NAME Cloud image ($CLOUD_IMAGE_VERSION)"
    log "----------------------------------------"
    sleep 2

    wget ${IMAGE_URL}

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

    rm -f ${IMAGE}
}

function destroy {
    qm destroy $id
}

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

mkdir -p logs

name=${name:-${DEFAULT_NAME}}
vm_name="$name-$NAME_SUFFIX"

ci_userdata_path=/var/lib/vz/snippets/${CI_USERDATA_FILE}
ci_userdata_url=https://github.com/luminosita/packer-snapshots/raw/refs/heads/main/config/cloudinit/${CI_USERDATA_FILE}

if [ $command == "create" ]; then
    create
elif [ $command == "destroy" ]; then
    destroy
else
    usage
fi