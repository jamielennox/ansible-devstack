#!/bin/bash

usage() {
    echo "Enter the SSH string (or a comma seperated list of machines) to the machine to connect to"
    echo ""
    echo "e.g. $0 <name> fedora@127.0.0.1"
    exit 1
}

if [ -z $1 ]; then
    usage
fi

# ${@:3} is parameters passed from 3 on, so anything after host will be passed
# to ansible-playbook so you can do --extra-vars "a=b" and pass it through
echo ansible-playbook -i \"$2,\" ${@:3} "$(dirname $0)/../playbooks/$1.yml"
ansible-playbook -i "$2," ${@:3} "$(dirname $0)/../playbooks/$1.yml"
