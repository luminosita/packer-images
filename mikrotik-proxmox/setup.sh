#!/bin/bash
usage() { echo "Usage: $0 -i vm_id -c ip_cidr -p temp_password";  echo "Example: $0 -i 100 -c 192.168.50.100 -p pass1234" 1>&2; return; }

while getopts ":i:c:p:" o; do
    case "${o}" in
        i)
            id=${OPTARG}
            # ((s == 45 || s == 90)) || usage
            ;;
        c)
            ip_cidr=${OPTARG}
            ;;
        p)
            password=${OPTARG}
            ;;
        *)
            usage

            return
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${id}" ] || [ -z "${ip_cidr}" ] || [ -z "${password}" ]; then
    usage

    return
fi

CHR_IP=$ip_cidr
TEMP_PASS=$password

echo "Coping scripts to Mikrotik VM ..."
sshpass -p $TEMP_PASS scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null rsc/*.rsc tmp/id_rsa.pub admin@$CHR_IP:/
sleep 2

echo "Running setup script..."
sshpass -p $TEMP_PASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$CHR_IP "/system/script/add name=\"setup\" source=[/file get [/file find where name=\"setup.rsc\"] contents];/system/script/run [find name=\"setup\"];/system/script/remove [find name=\"setup\"]"
sleep 5

ssh root@proxmox.lan "scripts/stop.sh -i "$id"; rm scripts/*"
