#!/bin/bash
echo "Creating bootstrap Mikrotik VM ..."
mkdir -p output
hcloud server create --image "$SNAPSHOT_ID" --location "fsn1" --type "cx22" --name "mikrotik-init" > output/server.log

SERVER_ID=`cat output/server.log | grep Server | sed -e s/Server\ // | sed -e s/\ created//`
CHR_IP=`cat output/server.log | grep IPv4 | sed -e s/IPv4:\ //`
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

echo "Creating snapshot ..."

hcloud server create-image --type snapshot --description "Mikrotik CHR Final - amd64 - 7.16.1" \
    --label arch="amd64" --label os="routeros" --label type="infra" --label version="7.16.1" $SERVER_ID

echo "Deleting server ..."

hcloud server delete $SERVER_ID
echo "Done."