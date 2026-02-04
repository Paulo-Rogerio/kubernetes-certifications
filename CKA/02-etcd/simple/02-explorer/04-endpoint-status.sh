#!/usr/bin/env bash

source ./01-env.sh
source /root/etcdctl.env

etcdctl endpoint status --write-out=table
