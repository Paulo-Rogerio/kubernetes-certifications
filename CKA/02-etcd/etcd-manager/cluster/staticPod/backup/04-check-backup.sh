#!/usr/bin/env bash

echo "####################################################"
echo " This script must be executed only in node master03 "
echo "####################################################"

etcdutl snapshot status /backup/etcd.db -w table
