#!/usr/bin/env bash

echo "####################################################"
echo " This script must be executed only in node master03 "
echo "####################################################"

cat > /root/etcdctl.env <<EOF
export ETCDCTL_ENDPOINTS=https://master03:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
EOF

source /root/etcdctl.env

mkdir -p /backup
etcdctl snapshot save /backup/etcd.db
