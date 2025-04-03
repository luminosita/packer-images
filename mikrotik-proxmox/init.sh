#!/bin/bash
usage() { echo "Usage: $0 -i vm_id -n name -t snapshot_id -v version -s storage";  echo "Example: $0 -i 100 -n Mikrotik -t 101 -v 7.16.1 -s local-zfs" 1>&2; return; }

while getopts ":i:n:v:t:s:" o; do
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
        t)
            snapshot_id=${OPTARG}
            ;;
        s)
            storage=${OPTARG}
            ;;
        *)
            usage

            return
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${id}" ] || [ -z "${name}" ] || [ -z "${version}" ] || [ -z "${snapshot_id}" ] || [ -z "${storage}" ]; then
    usage

    return
fi

scp scripts/*.sh root@proxmox.lan:~/scripts/

ssh root@proxmox.lan "chmod +x ~/scripts/*.sh"
ssh root@proxmox.lan "scripts/base.sh -i "$snapshot_id" -n Mikrotik-Vanilla -v "$version" -s "$storage
ssh root@proxmox.lan "scripts/clone.sh -i "$id" -t "$snapshot_id" -n "$name" -s "$storage
ssh root@proxmox.lan "scripts/start.sh -i "$id
