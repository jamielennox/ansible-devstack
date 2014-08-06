#!/bin/bash

if [ -z $1 ]; then
    echo "Enter the SSH string (or a comma seperated list of machines) to the machine to connect to"
    echo ""
    echo "e.g. $0 fedora@127.0.0.1"
    exit 1
fi

echo "ansible-playbook -i \"$1,\" devstack.yml"
ansible-playbook -i "$1," devstack.yml
