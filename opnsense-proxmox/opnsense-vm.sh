#!/bin/bash

usage() { echo "Usage: $0 -i vm_id -n name -v version -s storage";  echo "Example: $0 -i 100 -n OPNSense -v "25.1" -s vm-disks " 1>&2; exit 1; }

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

#UEFI BOOT
qm create $id \
	--name $name \
	--net0 virtio,bridge=vmbr0,queues=4 \
	--net1 virtio,bridge=vmbr1,queues=4 \
	--bootdisk scsi0 \
	--cpu cputype=x86-64-v2-AES,flags=+aes \
	--ostype l26 \
    --balloon 2048 \
	--memory 4096 \
	--onboot no \
	--sockets 1 \
	--cores 4 \
	--vga serial0 \
	--serial0 socket

wget https://mirror.fra10.de.leaseweb.net/opnsense/releases/mirror/OPNsense-$version-nano-amd64.img.bz2
bzip2 -d OPNsense-$version-nano-amd64.img.bz2

qemu-img convert \
    -f raw \
    -O qcow2 \
    OPNsense-$version-nano-amd64.img \
    OPNsense-$version-nano-amd64.qcow2

qemu-img resize OPNsense-$version-nano-amd64.qcow2 +27G

qm disk import $id OPNsense-$version-nano-amd64.qcow2 $storage

qm set $id \
    --scsihw virtio-scsi-single \
    --scsi0 $storage:vm-$id-disk-0,discard=on,iothread=1,ssd=1 \
    --boot order=scsi0 \
    --ipconfig0 ip=dhcp \
    --agent 1

rm OPNsense-$version-nano-amd64.img
rm OPNsense-$version-nano-amd64.qcow2
