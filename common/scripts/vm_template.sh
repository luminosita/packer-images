#!/bin/bash

# Log file
LOG_FILE="$dir/logs/template_creation_$(date +'%Y%m%d_%H%M%S').log"
SSH_KEY_PATH="$dir/gianni_rsa.pub"

# Function to log messages
log() {
  local timestamp=$(date +'[%Y-%m-%d %H:%M:%S]')
  echo "$timestamp $1" | tee -a "$LOG_FILE"
}

function qm_create_vm {
   #UEFI BOOT
    qm create ${1} \
        --name ${2} \
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
    qemu-img resize ${2} +4G

    qm disk import ${1} ${2} $storage
}

function qm_set_options {
    qm set ${1} \
        --scsihw virtio-scsi-single \
        --scsi0 ${2}:vm-${1}-disk-0,discard=on,iothread=1,ssd=1 \
        --boot order=scsi0 \
        --serial0 socket --vga serial0 \
        --ipconfig0 ip=dhcp \
        --agent 1 \
        --ide2 ${2}:cloudinit \
 	    --cicustom "user=local:snippets/$3" \
        --citype nocloud
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

if [ $command == "create" ]; then
    storage=${storage:-"local-lvm"}

    log "Downloading Cloud-init (vault-$vault_version)"
    log "----------------------------------------"
    sleep 2

    setup_cloud_init

    log "Downloading Alpine Cloud image ($alpine_version)"
    log "----------------------------------------"
    sleep 2

    wget ${imageUrl}

    log "Starting template creation"
    log "----------------------------------------"
    sleep 2

    qm_create_vm ${id} ${vm_name}

    log "VM created (ID: $id, Name: $vm_name, Storage: $storage)"
    log "----------------------------------------"
    sleep 2

    qm_import_disk ${id} ${image} ${ci_userdata_file}

    log "QCow2 disk imported"
    log "----------------------------------------"
    sleep 2

    qm_set_options ${id} ${storage} ${}

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