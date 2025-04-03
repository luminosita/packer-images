#!/bin/bash
usage() { echo "Usage: $0 -i vm_id";  echo "Example: $0 -i 100" 1>&2; exit 1; }

while getopts ":i:" o; do
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

if [ -z "${id}" ] ; then
    usage
fi

echo "Starting Mikrotik VM ..."

qm start $id


