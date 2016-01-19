#!/bin/bash

usage() {
    echo "Enter the SSH string (or a comma seperated list of machines) to the machine to connect to"
    echo ""
    echo "e.g. $0 --hostname openstack.jamielennox.net fedora@127.0.0.1"
    exit 1
}

options=$(getopt -l hostname -- "$@")

if [ ! options ]; then
    echo "options $options"
    usage
    exit 1
fi

while [ $# -gt 1 ]; do
    case "$1" in
        --hostname)
            hostname=$2
            shift
            ;;
        *)
            echo "Unknown argument $1"
            usage
            ;;
    esac
    shift
done

if [ -z $1 ]; then
    usage
fi

if [ $hostname ]; then
    extra_vars="--extra-vars \"hostname=$hostname\""
fi

echo ansible-playbook -i \"$1,\" $extra_vars "$(dirname $0)/../playbooks/common.yml"
ansible-playbook -i "$1," $extra_vars "$(dirname $0)/../playbooks/common.yml"
