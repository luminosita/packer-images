#!/bin/bash

usage() { echo "Usage: $0 -i vm_id ";  echo "Example: $0 -i 100" 1>&2; exit 1; }

while getopts ":i:n:v:s:" o; do
    case "${o}" in
        i)
            id=${OPTARG}
            # ((s == 45 || s == 90)) || usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${id}" ]; then
    usage
fi

echo "Creating snapshot ..."

qm stop $id &&
    qm template $id

echo "Done."