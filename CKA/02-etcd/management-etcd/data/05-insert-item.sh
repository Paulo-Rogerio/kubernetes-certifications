#!/usr/bin/env bash

source ./01-env.sh
source /root/etcdctl.env

etcdctl put "chave1" "value1"
etcdctl put "chave2" "value2"
etcdctl put "chave3" "value3"
