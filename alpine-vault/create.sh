#!/bin/bash

usage() { echo "Usage: $0 -i vm_id -n name -v version -m minor_version -d vault-version -s storage";  echo "Example: $0 -i 100 -n OPNSense -v 3.21 -m 2 -d 1.19.2 c-s local-lvm " 1>&2; exit 1; }

while getopts ":i:n:v:m:d:s:" o; do
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
        m)
            minor_version=${OPTARG}
            ;;
        d)
            vault_version=${OPTARG}
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

if [ -z "${id}" ] || [ -z "${name}" ] || [ -z "${version}" ] || [ -z "${minor_version}" ] || [ -z "${vault_version}" ] || [ -z "${storage}" ]; then
    usage
fi

#UEFI BOOT
qm create $id \
	--name $name \
	--net0 virtio,bridge=vmbr0,queues=4 \
	--bootdisk scsi0 \
	--cpu cputype=x86-64-v2-AES,flags=+aes \
	--ostype l26 \
    --balloon 256 \
	--memory 512 \
	--onboot no \
	--sockets 1 \
	--cores 1 \
	--vga serial0 \
	--serial0 socket

wget https://dl-cdn.alpinelinux.org/alpine/v${version}/releases/cloud/nocloud_alpine-${version}.${minor_version}-x86_64-bios-cloudinit-r0.qcow2

tee /var/lib/vz/snippets/vault-${vault-version}.yaml << wget -O - https://github.com/luminosita/packer-snapshots/raw/refs/heads/main/config/cloudinit/vault-${vault-version}.yaml

qemu-img resize nocloud_alpine-${version}.${minor_version}-x86_64-bios-cloudinit-r0.qcow2 +4G

qm disk import $id nocloud_alpine-${version}.${minor_version}-x86_64-bios-cloudinit-r0.qcow2 $storage

qm set $id \
    --scsihw virtio-scsi-single \
    --scsi0 $storage:vm-$id-disk-0,discard=on,iothread=1,ssd=1 \
    --boot order=scsi0 \
    --ipconfig0 ip=dhcp \
    --agent 1

qm set 9000 --cicustom "user=local:snippets/vault-${vault-version}.yaml"

rm nocloud_alpine-${version}.${minor_version}-x86_64-bios-cloudinit-r0.qcow2
