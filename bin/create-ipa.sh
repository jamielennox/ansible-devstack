#!/bin/bash

usage() {
    echo "Enter the SSH string (or a comma seperated list of machines) to the machine to connect to"
    echo ""
    echo "e.g. $0 jamielennox-fedtest.org fedora@127.0.0.1"
    exit 1
}

if [ -z $1 -o -z $2 ]; then
    usage
fi

echo ansible-playbook -i \"$2,\" --extra-vars \"domain=$1\"  \"$(dirname $0)/../playbooks/ipa-server.yml\"
ansible-playbook -i "$2," --extra-vars "domain=$1" "$(dirname $0)/../playbooks/ipa-server.yml"
