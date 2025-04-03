#!/bin/bash

usage() { echo "Usage: $0 -i vm_id -n name -v version -s storage";  echo "Example: $0 -i 100 -n Mikrotik -v "7.16.1" -s local-zfs " 1>&2; exit 1; }

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

wget https://download.mikrotik.com/routeros/$version/chr-$version.img.zip
unzip chr-$version.img.zip

qemu-img convert \
    -f raw \
    -O qcow2 \
    chr-$version.img \
    chr-$version.qcow2

qm create $id --name $name \
	--net0 virtio,bridge=vmbr0 \
	--bootdisk virtio0 \
	--machine q35 \
	--cpu host \
	--ostype l26 \
	--memory 256 \
	--onboot no \
	--sockets 1 \
	--cores 1 \
	--vga serial0 \
	--serial0 socket

qm disk import $id chr-$version.qcow2 $storage

qm set $id --scsihw virtio-scsi-pci \
	--virtio0 $storage:vm-$id-disk-0,discard=on \
	--boot order=virtio0 \
	--ipconfig0 ip=dhcp \
	--tags mikrotik-template,$version

qm template $id

rm chr-$version.*

