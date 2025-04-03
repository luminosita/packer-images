#!/bin/bash
usage() { echo "Usage: $0 -i vm_id -n name -t snapshot_id -s storage -m mac_address";  echo "Example: $0 -i 100 -n Mikrotik -t 101 -s local-zfs -m BC:24:11:7D:6B:91" 1>&2; exit 1; }

while getopts ":i:n:t:s:m:" o; do
    case "${o}" in
        i)
            id=${OPTARG}
            # ((s == 45 || s == 90)) || usage
            ;;
        n)
            name=${OPTARG}
            ;;
        t)
            snapshot_id=${OPTARG}
            ;;
        s)
            storage=${OPTARG}
            ;;
        m)
            mac=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${id}" ] || [ -z "${name}" ] || [ -z "${snapshot_id}" ] || [ -z "${storage}" ] || [ -z "${mac}" ]; then
    usage
fi


echo "Creating bootstrap Mikrotik VM ..."

qm clone $snapshot_id $id --name $name --full true --storage $storage && \
    qm set $id --tags "mikrotik-template,"$version && \
    qm set $id --net0 "virtio="$mac",bridge=vmbr0" && \
    qm start $id


