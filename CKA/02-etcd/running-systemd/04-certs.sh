#!/usr/bin/env bash

if [[ $(hostname -s) == "master01" ]]
then
  sh certs/01-ca.sh
  sh certs/02-check.sh
else
  mkdir -p /etc/kubernetes/pki/etcd
  scp root@master01:/etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd
  scp root@master01:/etc/kubernetes/pki/etcd/etcd.crt /etc/kubernetes/pki/etcd
  scp root@master01:/etc/kubernetes/pki/etcd/etcd.key /etc/kubernetes/pki/etcd
  ln -svf /etc/kubernetes/pki/etcd/etcd.crt /etc/kubernetes/pki/etcd/peer.crt
  ln -svf /etc/kubernetes/pki/etcd/etcd.key /etc/kubernetes/pki/etcd/peer.key
fi
