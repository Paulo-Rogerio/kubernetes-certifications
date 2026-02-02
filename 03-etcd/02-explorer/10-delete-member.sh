#!/usr/bin/env bash

[[ -z $1 ]] && echo "Member Id não informado. Liste os membros para obter o Id" && exit 1;

MEMBER_ID=$1

cat > /root/etcdctl.env <<EOF
export ETCDCTL_ENDPOINTS=https://master00:2379,https://master01:2379,https://master02:2379,https://master03:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/etcd.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/etcd.key
EOF

source /root/etcdctl.env

etcdctl member remove ${MEMBER_ID}
