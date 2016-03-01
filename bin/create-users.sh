#!/bin/bash

usage() {
    echo "Enter the SSH string (or a comma seperated list of machines) to the machine to connect to"
    echo ""
    echo "e.g. $0 fedora@127.0.0.1 devstack"
    echo "the -d flag will run devstack after creation"
    exit 1
}

if [ -z $1 ]; then
    usage
fi

# ip=$(echo $1 | cut -d '@' -f 2)
# sed -i -e "s/^$ip.*$//" ~/.ssh/known_hosts

# echo "ansible-playbook -i \"$1,\"  \"$(dirname $0)/../playbooks/users.yml\""
ansible-playbook -i "$1," "$(dirname $0)/../playbooks/users.yml"
