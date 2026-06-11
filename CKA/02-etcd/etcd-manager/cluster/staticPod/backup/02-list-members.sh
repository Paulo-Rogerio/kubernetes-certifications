#!/usr/bin/env bash

echo "####################################################"
echo " This script must be executed only in node master03 "
echo "####################################################"

source ./01-env.sh

etcdctl member list --write-out=table
