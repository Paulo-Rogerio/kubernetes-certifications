#!/usr/bin/env bash

cd $(dirname $0)

NAME=$(hostname -s)
NODE=$(ip -4 addr show enp1s0 | awk '/inet /{print $2}' | cut -d/ -f1)

nohup /usr/local/bin/etcd \
  --name ${NAME} \
  --client-cert-auth \
  --peer-client-cert-auth \
  --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \
  --cert-file=/etc/kubernetes/pki/etcd/etcd.crt \
  --key-file=/etc/kubernetes/pki/etcd/etcd.key \
  --peer-cert-file=/etc/kubernetes/pki/etcd/etcd.crt \
  --peer-key-file=/etc/kubernetes/pki/etcd/etcd.key \
  --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \
  --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \
  --data-dir=/var/lib/etcd \
  --initial-advertise-peer-urls https://${NODE}:2380 \
  --listen-peer-urls https://${NODE}:2380 \
  --advertise-client-urls https://${NODE}:2379 \
  --listen-client-urls https://${NODE}:2379,https://127.0.0.1:2379 \
  --initial-cluster-token estudos-etcd \
  --initial-cluster master01=https://master01:2380,master02=https://master02:2380,master03=https://master03:2380 \
  --initial-cluster-state existing > /var/log/etcd.log 2>&1 &
