#!/bin/bash

usage() { echo "Usage: $0 -i vm_id -n name -v version -s storage";  echo "Example: $0 -i 100 -n GNS3 -v "3.0.4" -s vm-disks " 1>&2; exit 1; }

while getopts ":i:n:v:s:" o; do
    case "${o}" in
        i)
            id=${OPTARG}
            # ((s == 45 || s == 90)) || usage
            ;;
        n)
            name=${OPTARG}
            ;;
        v)
            version=${OPTARG}
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

if [ -z "${id}" ] || [ -z "${name}" ] || [ -z "${version}" ] || [ -z "${storage}" ]; then
    usage
fi

wget https://github.com/GNS3/gns3-gui/releases/download/v$version/GNS3.VM.KVM.$version.zip
unzip GNS3.VM.KVM.$version.zip

qm create $id \
	--name $name \
	--net0 virtio,bridge=vmbr0 \
	--bootdisk scsi0 \
	--machine q35 \
	--cpu host \
	--ostype l26 \
    --balloon 2048 \
	--memory 16324 \
	--onboot no \
	--sockets 1 \
	--cores 4 \
	--vga serial0 \
	--serial0 socket

qm disk import $id "GNS3 VM-disk001.qcow2" $storage
qm disk import $id "GNS3 VM-disk002.qcow2" $storage

qm set $id \
    --scsihw virtio-scsi-pci \
    --scsi0 $storage:vm-$id-disk-0,discard=on \
    --scsi1 $storage:vm-$id-disk-1,discard=on \
    --boot order=scsi0 \
    --ipconfig0 ip=dhcp \
    --agent 1

rm GNS3.VM.KVM.$version.zip
rm "GNS3 VM-disk001.qcow2"
rm "GNS3 VM-disk002.qcow2"
