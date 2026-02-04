#!/usr/bin/env bash

cd $(dirname $0)

source ./01-env.sh
source /root/etcdctl.env

mkdir -p /etc/kubernetes/pki/etcd
scp root@master01:/etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd
scp root@master01:/etc/kubernetes/pki/etcd/etcd.crt /etc/kubernetes/pki/etcd
scp root@master01:/etc/kubernetes/pki/etcd/etcd.key /etc/kubernetes/pki/etcd

mkdir -p /var/lib/etcd
chmod 700 /var/lib/etcd

etcdctl member add master03 --peer-urls=https://master03:2380
