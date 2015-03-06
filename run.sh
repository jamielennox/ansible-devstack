#!/bin/bash

usage() {
    echo "Enter the SSH string (or a comma seperated list of machines) to the machine to connect to"
    echo ""
    echo "e.g. $0 fedora@127.0.0.1"
    echo "the -d flag will run devstack after creation"
    exit 1
}

while getopts ":d" o; do
    case "${o}" in
        d)
            devstack=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z $1 ]; then
    usage
fi

local ip=$(echo $1 | cut -d '@' -f 2)
sed -i -e "s/^$ip.*$//" ~/.ssh/known_hosts

# echo "ansible-playbook -i \"$1,\" devstack.yml"
ansible-playbook -i "$1," devstack.yml

if [ $devstack ]; then
    ssh $1 "~/devstack/unstack.sh; ~/devstack/stack.sh"
fi
