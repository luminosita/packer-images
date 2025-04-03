#!/bin/bash
usage() { echo "Usage: $0 -i vm_id -n name -t snapshot_id -v version -s storage -m mac -c ip_cidr";  echo "Example: $0 -i 100 -n Mikrotik -t 101 -v 7.16.1 -s local-zfs -m BC:24:11:7D:6B:91 -c 192.168.50.200" 1>&2; return; }

while getopts ":i:n:v:t:s:m:c:" o; do
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
        m)
            mac=${OPTARG}
            ;;
        c)
            ip_cidr=${OPTARG}
            ;;
        *)
            usage

            return
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${id}" ] || [ -z "${name}" ] || [ -z "${version}" ] || [ -z "${snapshot_id}" ] || [ -z "${storage}" ] || [ -z "${mac}" ] || [ -z "${ip_cidr}" ]; then
    usage

    return
fi

scp scripts/*.sh root@proxmox.lan:~/scripts/

ssh root@proxmox.lan "chmod +x ~/scripts/*.sh"
ssh root@proxmox.lan "scripts/base.sh -i "$snapshot_id" -n Mikrotik-Vanilla -v "$version" -s "$storage
ssh root@proxmox.lan "scripts/start.sh -i "$id" -t "$snapshot_id" -n "$name" -s "$storage" -m "$mac

CHR_IP=$ip_cidr
TEMP_PASS="laptop01"

echo "Waiting on VM network to start ..."
sleep 10
ping -t 30 -c 10 $CHR_IP

#Approve licence and set temp password
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$CHR_IP

echo "Coping scripts to Mikrotik VM ..."
sshpass -p $TEMP_PASS scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null rsc/*.rsc admin@$CHR_IP:/
sleep 2

echo "Running setup script..."
sshpass -p $TEMP_PASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$CHR_IP "/system/script/add name=\"setup\" source=[/file get [/file find where name=\"setup.rsc\"] contents];/system/script/run [find name=\"setup\"];/system/script/remove [find name=\"setup\"]"
sleep 5

ssh root@proxmox.lan "scripts/stop.sh -i "$id"; rm scripts/*"
