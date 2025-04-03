#!/bin/bash
usage() { echo "Usage: $0 -c ip_cidr -p temp_password";  echo "Example: $0 -c 192.168.1.88 -p pass1234" 1>&2; return; }

while getopts ":c:p:" o; do
    case "${o}" in
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

if [ -z "${ip_cidr}" ] || [ -z "${password}" ]; then
    usage

    return
fi

CHR_IP=$ip_cidr
TEMP_PASS=$password

#Approve licence and set temp password
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$CHR_IP

echo "Coping scripts to Mikrotik VM ..."
sshpass -p $TEMP_PASS scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null rsc/*.rsc tmp/id_rsa.pub admin@$CHR_IP:/
sleep 2

echo "Running setup script..."
sshpass -p $TEMP_PASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$CHR_IP "/system/script/add name=\"setup\" source=[/file get [/file find where name=\"setup.rsc\"] contents];/system/script/run [find name=\"setup\"];/system/script/remove [find name=\"setup\"]"
sleep 5

echo "Rebooting ..."
sshpass -p $TEMP_PASS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$CHR_IP "/system reboot"
sleep 5
