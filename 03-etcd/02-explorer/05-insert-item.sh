#!/usr/bin/env bash

source /root/etcdctl.env

etcdctl put "chave1" "value1"
etcdctl put "chave2" "value2"
etcdctl put "chave3" "value3"
