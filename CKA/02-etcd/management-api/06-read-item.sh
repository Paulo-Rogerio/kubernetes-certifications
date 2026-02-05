#!/usr/bin/env bash
source ./01-env.sh
source /root/etcdctl.env

echo "---------"
etcdctl get chave1 --prefix -w simple

etcdctl get chave1 --prefix -w json | jq .

echo "---------"
etcdctl get chave2 --prefix -w simple

etcdctl get chave2 --prefix -w json | jq .

echo "---------"
etcdctl get chave3 --prefix -w simple

etcdctl get chave3 --prefix -w json | jq .
echo "---------"
