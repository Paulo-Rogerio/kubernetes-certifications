#!/usr/bin/env bash

source /root/etcdctl.env

echo "---------"
etcdctl get chave1 --prefix

echo "---------"
etcdctl get chave2 --prefix

echo "---------"
etcdctl get chave3 --prefix
echo "---------"
